## <APB: Advanced Peri-Bus>

- ARM사가 개발한 저성능 장치 전용 버스 I/F
- APB 브릿지(Master) -> 저성능 장치(Slave)

#### 인터페이스

- **write** : 0(Read), 1(Write)
- **sel, addr**: 어떤 slave의 어떤 레지스터? (몇동 몇호?)
- **en(M)** : 데이터 받을 준비됨??
- **ready(S)** : ㅇㅇ
- **wdata, rdata**
  > 마스터는 통신에 필요한 값(sel, addr, write, data)을 세팅하며, Slave에게 1클럭의 읽을 시간을 준다.
  > 그 이상이 필요한 경우 Slave가 ready로 필요한만큼 Stall(WAIT)하는 구조
- **state**
  - **IDLE**
  - **SETUP**: **Set** sel, addr, data & **en, ready LOW**
  - **ACCESS**: SETUP + **en HIGH**
