## Async FIFO
### Why : Clock Domain Crossing (CDC)
- Metastability
- pulse signal
  
### How
- wptr, rptr
- 2-ff synchronizer
- gray code 변환기

- <Interconnect>
Why FIFO 
=> Buffer + udf,ovf 방지
1) Width/Depth
2) Almost Full/Empty
- queue: insertTail
- stack: insertHead
- always read Head

push(write)
pop(read & shift)

Why Async_FIFO
=> Clock Domain Crossing??
=> 다른 클럭을 쓰는 경우 동기화 문제
=> A클럭의 에지에서 캡처하는 경우 메타스테빌리티
=> 안정될때까지 시간을 끌어주는게 동기화 장치
=> 단순히 dff 하나더 쓰나?
Passing short CDC signal

Circular Buffer
=> wptr로 쓰고, rptr로 읽는다.
=> rptr이 지나간 자리는 wptr로 쓰기 전에
접근할 수 없는 자리가 된다.
