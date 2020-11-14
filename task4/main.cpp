#include <iostream>
#include <vector>
#include "pthread.h"

std::vector<int> shared(8);

struct LR {
    int l;
    int r;
};

void *calculate(void *param) {
    LR *lr = (LR *) param;
    int l = lr->l;
    int r = lr->r;
    int *res = new int;
    if (l == r) {
        *res = shared[l];
        return (void *) (res);
    }
    pthread_t thread1, thread2;
    LR first_lr{l, (l + r) / 2};
    pthread_create(&thread1, nullptr, calculate, (void *) &first_lr);
    LR second_lr{(l + r) / 2 + 1, r};
    pthread_create(&thread2, nullptr, calculate, (void *) &second_lr);
    int *first_sum;
    pthread_join(thread1, (void **) &first_sum);
    int *second_sum;
    pthread_join(thread2, (void **) &second_sum);
    (*res) = (*first_sum) + (*second_sum);
    delete first_sum;
    delete second_sum;
    return (void *) res;
}

int main() {
    int origin_sum;
    std::cout << "Input original sum ";
    std::cin >> origin_sum;

    for (int i = 0; i < 8; ++i) {
        std::cout << "Input shared [" << i + 1 << "] ";
        std::cin >> shared[i];
    }

    LR lr{0, 7};
    int *shared_sum = (int *) calculate((void *) &lr);
    if ((*shared_sum) != origin_sum) {
        std::cout << "Lawyer is liar" << std::endl;
    } else {
        std::cout << "Good lawyer" << std::endl;
    }
    delete shared_sum;
    return 0;
}
