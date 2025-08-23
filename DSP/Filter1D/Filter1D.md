# 컨볼루션

> 1. 시간차 입력과 커널의 MAC 연산
> 2. 유사도를 출력 (패턴인식 관점)
> 3. 원하는 주파수 성분만 filtering (DSP 관점)
>   - LPF: 노이즈 제거(blur)
>   - HPF: 엣지 검출(변화 강조)

## Filter 구현

- 길이 N인 커널 h[k] (N-tap Kernel; 시스템의 Impulse Response)
- 현재 입력과 이전 M-1 개의 입력을 저장하는 배열 x[n-k]
- Σ h(k)*x(n-k); [k = 0 ~ M-1] : MAC 연산
- **C 구현**: [Filter.c](./filter.c)


### 검증 (Octave)
- output.txt 파일을 gnu-octave를 사용하여 검증
- **구현**: [spectrum.m](test/spectrum.m)

<img src="spectrum_out.png" width=500 height=400>

# Fixed-Point로 구현

## Fixed-Point MAC

> 표기: **(m, f)** = 총 m비트 중 소수 f비트.  
> 값의 범위(2’s complement >> f):  \[
-\frac{2^{m-1}}{2^f} \le X \le \frac{2^{m-1}-1}{2^f}
\]

---

### 1) 곱셈 비트폭
- 기본:  
  \[
  (m_1,f_1)\times(m_2,f_2)\Rightarrow \boxed{(m_1+m_2,\ f_1+f_2)}
  \]
- **대칭 포화 가정**(입력의 최솟값 −2^{m−1} 배제) 시:  
  \[
  \boxed{(m_1+m_2-1,\ f_1+f_2)}
  \]
- 왜 1비트 절약?  
  최악 케이스 \((−2^{m-1})\times(−2^{m-1})\)를 미리 금지 → 최대곱이 한 단계 내려감.

**예)** (8,4)×(8,5) → (15,9) 〈대칭 포화〉

---

### 2) 누산(덧셈) 비트폭
- 같은 스케일 항 **N개** 합:  
  \[
  \boxed{(m_\text{mul}+\lceil\log_2 N\rceil,\ f_\text{mul})}
  \]
  (여기서 \(m_\text{mul}, f_\text{mul}\)은 “곱 한 항”의 m,f)

- 더 타이트하게 잡기(선택):  
  \[
  \lceil\log_2 N\rceil \;\Longrightarrow\; \lceil\log_2 \sum |h_i|\rceil
  \]
  (계수 \(\sum|h_i|\)가 1.5 등으로 작으면 여유 비트를 줄여도 됨)

**예)** (8,4)×(8,5) ⇒ (15,9), 탭 21개 ⇒ (15+5, 9) = **(20,9)**

---

### 3) 라운딩 & 클램핑(=포화)

> 목적: 컨볼루션(MAC 연산) 결과를 **목표 소수 f_out**으로 내리면서  
> 품질 손실을 최소화(라운딩)하고, **표현 범위 밖** 값은 양끝에 붙여 안전화(포화=클램핑)한다.

```c
out = (out+(1<<15)) >> 16;   // out: 정수형
if(out > 32767) out = 32767; // 1 << 15 = 32768
else if(out < -32767) out = -32767;
```

- **C 구현**: [filter_fixed.c](test/filter_fixed.c)
- **Verilog 구현**: 
  - [filter.v](test/filter.v)
  - [tb_filter.sv](test/tb_filter.sv)
