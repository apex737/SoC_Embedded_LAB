## 1. Handshake Buffer

<table>
<tr>
 <td align="left"><img src="IMG/img1.png" width=400 height=200></td>
 <td align="right"><img src="IMG/img2.png" width=200 height=200>
</td>
</tr>
</table>

- **Prefix s, m**은 **DUT의 입장에서** 들이거나(slave) 내보내는(master) 신호를 표현한 것임
- **s_ready(ce) = ~m_valid | m_ready**
  - **HS-Shift-Reg**는 M/S를 연결하는 파이프
  - **m_valid가 0**이면 파이프가 전부 비었다는 뜻이므로 파이프에 새로운 값을 넣을 수 있음
  - **m_ready가 1**이면 파이프에서 값이 빠져나가기 때문에 새로운 값을 넣을 수 있음
- **i_hs = s_ready & s_vaild**
  - **Stimulus**는 **i_hs**에서 **Write**
- **m_hs = m_ready & m_valid**
  - **Checker**는 **o_hs**에서 **Read**

## 2. Skid Buffer

<table>
<tr>
 <td align="right"><img src="IMG/img4.png" width=400 height = 200></td>
</tr>
</table>

- Handshake Buffer가 Cascade 되는 경우 OR-Gate에 의해 타이밍 위반이 발생하므로, 이를 방지하기 위해 버퍼를 삽입함

<table>
<tr>
 <td align="right"><img src="IMG/img6.png" width=400 
 height = 200></td>
 <td align="right"><img src="IMG/img6.jpg" width=400 height = 200></td>
</tr>
</table>

- Skid Buffer는 ~ready 상태에서만 활성화되는 **Pipe-Through 레지스터**로, ~ready 상태(SKID)가 지속되는 한 이전 데이터를 Skid Buffer에 저장함 **(Pipeline Stall)**
- ready가 HIGH가 되면 **SKID -> PIPE** 로 상태를 전이하면서 데이터를 넘김

## 3. I/F 장단점

<img src="IMG/img5.png" width=400 height = 200>

- **Ready-Vaild I/F**는 가장 많은 AREA를 지불해야 하지만, No I/F 및 Valid I/F와 호환 가능하며, **무손실 데이터 전송**의 이점으로 인해 널리 사용됨
- Ready-Valid I/F와 호환하기 위해 **No I/F**는 Ready/Valid를 1로 Tie, **Valid I/F**는 Ready를 1로 Tie하여 사용함
