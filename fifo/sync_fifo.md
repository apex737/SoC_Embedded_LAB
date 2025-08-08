## Why Sync FIFO?

#### 1. Buffering

- Write Side와 Read Side의 속도가 다른 경우 그 차이만큼 지연(Stall)이 발생하게 됨
- 이 속도 차이를 극복할 수 있는 적절한 DEPTH의 FIFO를 쓰면 Stall을 줄이거나 없애서 성능을 향상시킬 수 있음

#### 2. Latency Balancing

<img src=img1.png>
  
- 데이터를 A, B 채널로 나눠서 처리한 뒤 합치는 경우 Latency 차이에 의해 더 빠른 쪽(B 채널)이 멈추는 상황이 발생함
- 채널 하나가 막히면 Split-Input이 멈추고, 이로 인해 새로운 입력도 멈추는 상황이 발생함 **(Deadlock)**
- 이 문제는 채널 간 **Latency 차이만큼 FIFO DEPTH를 맞춰주는 것으로 해결 가능**
