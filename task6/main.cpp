#include <iostream>
#include <vector>
#include <pthread.h>
#include <memory>
#include <semaphore.h>
#include <thread>
#include <chrono>

const int CLIENT_NUM = 100;
const int MAX_GALLERY_CLIENTS = 50;
const int PICTURES_COUNT = 5;
const int MAX_PICTURE_CLIENTS_COUNT = 10;
const int MAX_CLIENT_WATCH_COUNT = 10;

struct Picture {
    Picture() {
        sem_init(&pic_sem, 0, MAX_PICTURE_CLIENTS_COUNT);
    }

    sem_t pic_sem{};
};

struct Gallery {
    std::vector<Picture> pics = std::vector<Picture>(PICTURES_COUNT);
};

class Watchman {
public:
    Watchman() {
        limit_sem = sem_t();
        sem_init(&limit_sem, 0, MAX_GALLERY_CLIENTS);
    }

    Gallery *getGallery(int id) {
        std::printf(">>>Client %d is waiting for watchman's allow\n", id);
        sem_wait(&limit_sem);
        std::printf(">>>Watchman allowed entrance for client %d\n", id);
        return gallery.get();
    }

    void leaveGallery(int id) {
        std::printf("<<<Client left the gallery %d\n", id);
        sem_post(&limit_sem);
    }

private:
    sem_t limit_sem{};
    std::unique_ptr<Gallery> gallery = std::make_unique<Gallery>();
};

Watchman watchman;

class Client {
public:
    Client(int id) : id(id) {}

    void run() {
        pthread_create(&thread, nullptr, goToGallery, (void *) &id);
    }

    void join() const {
        pthread_join(thread, nullptr);
    }

private:
    int id;
    pthread_t thread;

    static void *goToGallery(void *param) {
        int id = *((int *) param);
        auto gallery = watchman.getGallery(id);

        int watches_lim = rand() % MAX_CLIENT_WATCH_COUNT;
        for (int i = 0; i < watches_lim; ++i) {
            int pic_id = rand() % gallery->pics.size();
            std::printf("\tClient %d is waiting for place around picture %d\n", id, pic_id);
            sem_t &sem = gallery->pics[pic_id].pic_sem;
            sem_wait(&sem);
            std::printf("\tClient %d started to watch on picture %d\n", id, pic_id);
            std::this_thread::sleep_for(std::chrono::seconds(1)); // wait
            sem_post(&sem);
            std::printf("\tClient %d ended to watch on picture %d\n", id, pic_id);
        }
        watchman.leaveGallery(id);
        return nullptr;
    }
};

int main() {
    std::vector<Client> clients;
    clients.reserve(CLIENT_NUM);
    for (int i = 0; i < CLIENT_NUM; ++i) {
        clients.emplace_back(i);
    }
    for (auto &client : clients) {
        client.run();
    }
    for (auto &client : clients) {
        client.join();
    }
    return 0;
}
