import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

# 实验数据
points = np.array([32, 64, 128, 256, 512, 1024, 2048, 4096])
dft_times = np.array([0.056, 0.178, 0.616, 2.621, 10.198, 40.158, 159.715, 646.320])
fft_times = np.array([0.005, 0.008, 0.020, 0.029, 0.065, 0.170, 0.315, 0.679])

# 定义理论复杂度函数
def n_squared(n, a):
    return a * n**2

def n_log_n(n, a):
    return a * n * np.log2(n)

# 创建图表
plt.figure(figsize=(12, 8))

# DFT时间复杂度验证 - O(N²)
plt.subplot(1, 2, 1)
# 拟合O(N²)曲线
popt_dft, _ = curve_fit(n_squared, points, dft_times)
n_range = np.linspace(30, 4100, 100)
dft_fit = n_squared(n_range, *popt_dft)

plt.loglog(points, dft_times, 'ro-', linewidth=2, markersize=8, label='DFT real time')
plt.loglog(n_range, dft_fit, 'r--', linewidth=2, label=f'O(N²)')
plt.xlabel('N')
plt.ylabel('calculated time (ms)')
plt.title('DFT time complex verify')
plt.grid(True, which="both", ls="-", alpha=0.3)
plt.legend()

# FFT时间复杂度验证 - O(NlogN)
plt.subplot(1, 2, 2)
# 拟合O(NlogN)曲线
popt_fft, _ = curve_fit(n_log_n, points, fft_times)
fft_fit = n_log_n(n_range, *popt_fft)

plt.loglog(points, fft_times, 'bo-', linewidth=2, markersize=8, label='FFT real time')
plt.loglog(n_range, fft_fit, 'b--', linewidth=2, label=f'O(NlogN)')
plt.xlabel('N')
plt.ylabel('calculated time (ms)')
plt.title('FFT time complex verify')
plt.grid(True, which="both", ls="-", alpha=0.3)
plt.legend()

plt.tight_layout()
plt.show()

# 输出拟合结果
print("时间复杂度验证结果:")
print(f"DFT拟合函数: time = {popt_dft[0]:.2e} × N²")
print(f"FFT拟合函数: time = {popt_fft[0]:.2e} × NlogN")