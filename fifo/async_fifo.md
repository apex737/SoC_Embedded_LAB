## Async FIFO
### Why : Clock Domain Crossing (CDC)
* __Metastability__
* __Passing short CDC signal__
* __Why Gray Code__
  
### How
* wptr, rptr base circular fifo
  * __Circular Buffer__
    * wptr로 쓰고, rptr로 읽는다.
    * rptr이 지나간 자리는 wptr로 쓰기 전에 접근할 수 없는 자리가 된다. 
* 2-ff synchronizer
* bin to gray 변환기

__Why Async_FIFO__
* 다른 클럭을 쓰는 경우 동기화 문제
* A클럭의 에지에서 캡처하는 경우 메타스테빌리티
* 안정될때까지 시간을 끌어주는게 동기화 장치; 단순히 dff 하나 더 쓰나?
  
  



