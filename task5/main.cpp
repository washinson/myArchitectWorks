#include <iostream>
#include <vector>
#include <omp.h>

std::vector<int> shared(8);

struct LR {
    int l;
    int r;
};

int calculate(const LR &lr) {
    int l = lr.l;
    int r = lr.r;
    int res;
#pragma omp critical
    {
        std::cout << "I'm " << omp_get_thread_num() << "+" << omp_get_num_threads() << " and have l=" << l << " r=" << r
                  << std::endl;
    }
    if (l == r) {
        res = shared[l];
        return res;
    }
    int sum = 0;
#pragma omp parallel for reduction (+: sum) num_threads(2)
    for (int i = 0; i < 2; ++i) {
        LR my_lr{l, (l + r) / 2};
        if (i == 1) {
            my_lr = {(l + r) / 2 + 1, r};
        }
        int sub_res = calculate(my_lr);
        sum += sub_res;
    }
    res = sum;

    return res;
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
    int shared_sum = calculate(lr);
    if (shared_sum != origin_sum) {
        std::cout << "Lawyer is liar" << std::endl;
    } else {
        std::cout << "Good lawyer" << std::endl;
    }
    return 0;
}
