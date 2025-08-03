## Clock Domain Crossing (CDC)
> 다른 클럭을 사용하는, 즉 말하는 속도가 다른 두 Domain은 서로 간에 어떻게 데이터를 주고 받을 것인가?
#### 문제1. Passing short CDC signal
> 더 빠른 클럭을 쓰는 영역 A에서 전송하는 경우, 느린 클럭 영역 B에서 수신하지 못하는 문제

* __특히, 데이터가 빠른 A로부터 짧은 펄스로 전송되는 경우__ 느린 B가 그 속도를 못 따라잡기 때문에, 다시말해 F/F의 CLK_Edge에서 캡처하지 못하기 때문에 데이터 손실이 일어나게 된다.
* 타이밍 문제의 일반적인 해법은 __AREA를 더 쓰는 것__; 버퍼를 중간에 삽입하는 것이다. 또한, 두 영역에서 읽기/쓰기 포인터(wptr, rptr)를 주고받으며 버퍼가 비었으면 읽지 못하게, 버퍼가 가득찼으면 쓰지 못하게 제어하면 될 것이다.
* __PTR Base Circular Buffer__
    * N = 8인 fifo라면 ptr은 0~7의 인덱스를 단순 증가하면서 순회하게 된다.
        * __<Ex>__ wptr이 0~7까지 쓰고 8이 되었을 때, rptr이 0-4까지 읽으면, wptr은 0-4에 쓸 수 있게된다.
        * __full: wptr - rptr = N__
        * __empty: wptr - rptr = 0__
        
* 그러나, wptr/rptr은 CDC-signal(Async)이므로 통과 경계에서 문제가 된다.

#### 문제 2. Metastability
> Async Signal이 Sync-Domain으로 들어올 때 Metastable Data(meta)가 발생하는 문제

__1) Syncronizer__
> meta는 결국에 하나의 값으로 결정되나, 문제는 그 결과를 예측할수 없다는 것이다.

* 이 경우, 주로 2-ff 동기화기를 써서 meta를 자기 영역에 동기화시켜서 해결한다.
* 예컨대, 입력이 HIGH인 상황에서 바로 다음 클럭에
  * __0 -> meta -> 1:__ 운좋게 값이 의도대로 잘 출력됨 -> okay
  * __0 -> meta -> 0:__ 운나쁘게 값이 의도대로 출력되지 않음 -> 다음 클럭에는 meta가 아닌 안정된 1이 들어오므로 okay
  * __이로써, meta 문제가 단순 2-클럭 지연으로 바뀐다.__
    
__2) Bin2Gray 변환기__
> multi-bit 전송에서 metastability 문제의 해법 

* 영역 A의 wptr, 영역 B의 rptr은 binary 카운터처럼 동작한다. 그러나, Async-FIFO 내부의 ptr 송수신에서까지 binary 방식을 그대로 전달하면 치명적인 문제가 발생할 수 있다.
* 예컨대, 카운터가 011(bin_3) -> 100(bin_4) 으로 바뀌는 경우 3개의 신호선 모두 meta를 가지기 때문에 000에서 111까지 모든 값이 출력될 수 있다. 그러나 Bitwise-XOR는 변화만을 감지할 수 있기 때문에 뭐든지 바뀌기만하면 유효한 값처럼 전달되므로 시스템이 망가지게 된다.
* 반면에, 010(gray_3) -> 110(gray_4) 으로 카운터가 바뀌는 경우 sigle-bit만 변화하기 때문에 앞의 sigle-bit 상황으로 문제를 축소할 수 있다.
  * __010 -> meta -> 110:__ 운좋게 값이 의도대로 잘 출력됨 -> okay
  * __010 -> meta -> 010:__ 운나쁘게 값이 의도대로 출력되지 않음 -> 다음 클럭에는 meta가 아닌 안정된 값이 들어오므로 okay
  * __이로써, meta 문제가 단순 2-클럭 지연으로 바뀐다.__
  
```verilog
/*      Implement Flow

        1) set rptr, wptr for  fifo
        2) 2-ff synchronizer
        3) bin2gray
        4) define strobs
*/

module async_fifo();

endmodule
```


