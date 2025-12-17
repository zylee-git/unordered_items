import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
import warnings
warnings.filterwarnings('ignore')

def analyze_given_signal():
    """
    对给定信号 s(t)=0.8×sin(2π×103t) + sin(2π×107t) + 0.1×sin(2π×115t) 进行频谱分析
    """
    
    # 信号参数
    f1, f2, f3 = 103, 107, 115  # 信号频率成分 (Hz)
    A1, A2, A3 = 0.8, 1.0, 0.1  # 对应的幅值
    
    print("=" * 60)
    print("signal analyze: s(t) = 0.8×sin(2π×103t) + sin(2π×107t) + 0.1×sin(2π×115t)")
    print("=" * 60)
    
    # 采样参数设置
    fs = 256  # 采样率
    N = 256  # 采样点数
    T = float(N / fs)  # 采样时长
    t = np.linspace(0, T, N, endpoint=False)

    # 生成信号
    s = (A1 * np.sin(2 * np.pi * f1 * t) + 
         A2 * np.sin(2 * np.pi * f2 * t) + 
         A3 * np.sin(2 * np.pi * f3 * t))
    
    # 显示分析参数
    print("\n频谱分析参数设置：")
    print(f"采样率 (fs): {fs} Hz")
    print(f"采样时长 (T): {T} s")
    print(f"采样点数 (N): {N}")
    print(f"频率分辨率 (Δf = fs/N): {fs/N:.3f} Hz")
    print(f"可分析的最高频率 (fs/2): {fs/2} Hz")
    print(f"信号频率成分: {f1} Hz, {f2} Hz, {f3} Hz")
    print(f"最小频率间隔: {min(f2-f1, f3-f2)} Hz")
    
    # 使用不同窗函数进行对比分析
    windows = [
        ('rectangle', np.ones(N), 'blue'),
        ('hanning', np.hanning(N), 'red'),
        ('hamming', np.hamming(N), 'green'),
        ('blackman', np.blackman(N), 'purple')
    ]
    
    # 创建图形
    plt.figure(figsize=(12, 8))
    
    # 绘制原始信号
    plt.subplot(3, 1, 1)
    plt.plot(t, s)
    plt.title('original signal s(t) = 0.8×sin(2π×103t) + sin(2π×107t) + 0.1×sin(2π×115t)')
    plt.xlabel('time (s)')
    plt.ylabel('amplititude')
    plt.grid(True)
    
    # 频谱分析
    plt.subplot(3, 1, 2)
    
    for win_name, window, color in windows:
        # 加窗
        s_windowed = s * window
        
        # FFT计算
        S = np.fft.fft(s_windowed)
        freqs = np.fft.fftfreq(N, 1/fs)
        
        # 取正频率部分
        positive_freq_idx = (freqs >= 80) & (freqs <= 140)  # 聚焦在信号频率附近
        freqs_positive = freqs[positive_freq_idx]
        magnitude = np.abs(S[positive_freq_idx]) / (N * np.sum(window) / N)
        
        # 绘制频谱
        plt.plot(freqs_positive, magnitude, 
                label=win_name, color=color, linewidth=2)
        
        # 分析峰值
        peaks, properties = signal.find_peaks(magnitude, height=0.01, distance=3)
        if len(peaks) > 0:
            print(f"\n{win_name}峰值检测:")
            for j, peak in enumerate(peaks[:6]):  # 显示前6个峰值
                freq_peak = freqs_positive[peak]
                mag_peak = magnitude[peak]
                print(f"  峰值 {j+1}: 频率={freq_peak:6.2f} Hz, 幅值={mag_peak:6.4f}")
    
    # 标记理论频率位置
    for f, A, color in [(f1, A1, 'red'), (f2, A2, 'blue'), (f3, A3, 'green')]:
        plt.axvline(x=f, color=color, linestyle='--', alpha=0.7, 
                   label=f'theoretical frequency {f}Hz')
    
    plt.title('different window functions (80-140 Hz)')
    plt.xlabel('frequency (Hz)')
    plt.ylabel('amplititude')
    plt.legend()
    plt.grid(True)
    
    # 详细分析最佳窗函数（汉宁窗）
    plt.subplot(3, 1, 3)
    window = np.hanning(N)
    s_windowed = s * window
    S = np.fft.fft(s_windowed)
    freqs = np.fft.fftfreq(N, 1/fs)
    
    positive_freq_idx = (freqs >= 80) & (freqs <= 140)
    freqs_positive = freqs[positive_freq_idx]
    magnitude = np.abs(S[positive_freq_idx]) / (N * np.sum(window) / N)
    
    plt.plot(freqs_positive, magnitude, 'b-', linewidth=2, label='hanning window')
    
    # 标记峰值
    peaks, properties = signal.find_peaks(magnitude, height=0.01, distance=2)
    for peak in peaks:
        plt.plot(freqs_positive[peak], magnitude[peak], 'ro', markersize=8)
        plt.annotate(f'{freqs_positive[peak]:.1f}Hz\n({magnitude[peak]:.3f})',
                    xy=(freqs_positive[peak], magnitude[peak]),
                    xytext=(10, 10), textcoords='offset points',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.7))
    
    # 标记理论值
    for f, A in [(f1, A1), (f2, A2), (f3, A3)]:
        plt.axvline(x=f, color='red', linestyle='--', alpha=0.5)
        plt.annotate(f'theoretical:{f}Hz', xy=(f, 0.9*A), 
                    xytext=(5, 5), textcoords='offset points',
                    rotation=90, alpha=0.7)
    
    plt.title('hanning window detailed analyze')
    plt.xlabel('frequency (Hz)')
    plt.ylabel('amplititude')
    plt.legend()
    plt.grid(True)
    
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    analyze_given_signal()