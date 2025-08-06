## 1. Handshake Buffer

<img src="img1.png" width=400 height=200>

- **s_ready(ce) = ~m_valid | m_ready**
  - **HS-Shift-Reg**는 M/S를 연결하는 파이프
  - **m_valid가 0**이면 파이프가 전부 비었다는 뜻이므로 파이프에 새로운 값을 넣을 수 있음
  - **m_ready가 1**이면 파이프에서 값이 빠져나가기 때문에 새로운 값을 넣을 수 있음

## 2. Skid Buffer
