# Field Programmable Gate Array

> 프로그램에 필요한 Block들과 Interconnect만 **선택적으로 On/Off 하여 사용**할 수 있기 때문에 FPGA를 **Re-programmable** 하다고 하며, 이로 인해 **Multiple-Bitstream**이 가능하고 **Low Bug Fix Cost**의 이점을 얻음

### Essentials (General)

**1. CLB: Configurable Logic Block**

<table>
<tr>
<th>FPGA Structure</th>
<td text-align="left">
<img src="Configuration.png" width=500 height=300>
</td>
<th>CLB Structure</th>
<td text-align="right">
<img src="CLB.jpg" width=300 height = 400>
</td>
</tr>
</table>

- **LUT :** Combinational 연산을 지원하기 위한 Look Up Table
- **Carry Logic :** ALU를 지원하기 위한 로직; LUT AREA를 최소화하는 용도
- **Sequential Element**
- **Mux**

**2. IOB (Input/Output Buffer) :** 외부 소자들과 통신하기 위한 버퍼
**3. Programmable Interconnect (Vertical/Horizontal Routing Channel) :** 라우팅 경로 최적화(필요한 경로만 선택)

---

### Dedicated Block (Specific)

> Essential Block만으로 동작은 하지만, PPA가 구리기 때문에 이를 최적화 하기 위해 추가되는 Block

- **BRAM**
- **DSP**
- **PLL**
- **Serial Tx**

---

## PS/PL

> **PS의 목적**
>
> - PL 제어신호 전송
> - PL(HW) 연산 성능 향상을 PS(ARM) 연산과 1:1 비교

<img src="PS_PL.png" width=500 height=500>

1. **vivado proj 생성**
2. **(필요한 경우) ip package customize**
3. **block design 생성 (ip integration)**
   - zynq ip 생성
     - 사용할 PS 영역 선택 & 전압 설정
   - custom ip package 추가 & zynq ip와 연결 (clk, rst 등)
   - F6 (Validation Check)
   - Wrapper & Bitstream 생성
4. **Export HW (Bitstream 포함)**
5. **Vitis: Platform(xsa) Proj 생성 --> App Proj 생성**
6. **PS Coding**
