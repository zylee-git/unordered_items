#include <iostream>
#include <vector>
#include <complex>
#include <cmath>
#include <chrono>
#include <algorithm>
#define M_PI 3.14159265358979323846  // pi

using namespace std;
using namespace std::chrono;

typedef complex<double> Complex;

// 直接计算DFT
vector<Complex> dft(const vector<Complex>& x) {
    int N = x.size();
    vector<Complex> X(N);
    
    for (int k = 0; k < N; k++) {
        X[k] = 0;
        for (int n = 0; n < N; n++) {
            double angle = -2 * M_PI * k * n / N;
            X[k] += x[n] * exp(Complex(0, angle));
        }
    }
    return X;
}

// 基2 FFT（迭代版本）
vector<Complex> fft(const vector<Complex>& x) {
    int N = x.size();
    
    // 检查是否为2的整数次幂
    if ((N & (N - 1)) != 0) {
        throw invalid_argument("输入长度必须是2的整数次幂");
    }
    
    // 位反转置换
    vector<Complex> X = x;
    for (int i = 1, j = 0; i < N; i++) {
        int bit = N >> 1;
        while (j >= bit) {
            j -= bit;
            bit >>= 1;
        }
        j += bit;
        if (i < j) {
            swap(X[i], X[j]);
        }
    }
    
    // 迭代FFT
    for (int L = 2; L <= N; L <<= 1) {
        double angle = -2 * M_PI / L;
        Complex wlen(cos(angle), sin(angle));
        
        for (int i = 0; i < N; i += L) {
            Complex w(1);
            for (int j = 0; j < L/2; j++) {
                Complex u = X[i + j];
                Complex v = w * X[i + j + L/2];
                X[i + j] = u + v;
                X[i + j + L/2] = u - v;
                w *= wlen;
            }
        }
    }
    
    return X;
}

// 生成测试信号
vector<Complex> generate_test_signal(int N) {
    vector<Complex> x(N);
    for (int i = 0; i < N; i++) {
        // 包含多个频率成分的信号
        x[i] = sin(2 * M_PI * 50 * i / N) + 
               0.5 * sin(2 * M_PI * 120 * i / N) +
               0.3 * sin(2 * M_PI * 200 * i / N);
    }
    return x;
}

// 计算误差
double calculate_error(const vector<Complex>& X1, const vector<Complex>& X2) {
    double error = 0;
    for (size_t i = 0; i < X1.size(); i++) {
        error += abs(X1[i] - X2[i]);
    }
    return error / X1.size();
}

int main() {
    vector<int> sizes = {32, 64, 128, 256, 512, 1024, 2048, 4096};
    
    cout << "FFT vs DFT 性能比较\n";
    cout << "点数\tDFT时间(ms)\tFFT时间(ms)\t速度比\t\t误差\n";
    cout << "------------------------------------------------------------\n";
    
    for (int N : sizes) {
        vector<Complex> x = generate_test_signal(N);
        
        // DFT计算时间
        auto start = high_resolution_clock::now();
        vector<Complex> X_dft = dft(x);
        auto end = high_resolution_clock::now();
        auto dft_time = duration_cast<microseconds>(end - start).count() / 1000.0;
        
        // FFT计算时间
        start = high_resolution_clock::now();
        vector<Complex> X_fft = fft(x);
        end = high_resolution_clock::now();
        auto fft_time = duration_cast<microseconds>(end - start).count() / 1000.0;
        
        // 计算误差
        double error = calculate_error(X_dft, X_fft);
        
        printf("%d\t%.3f\t\t%.3f\t\t%.1f\t\t%.2e\n", 
               N, dft_time, fft_time, dft_time/fft_time, error);
    }
    
    return 0;
}