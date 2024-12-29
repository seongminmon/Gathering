# <img src="https://hackmd.io/_uploads/H1gRpEHByg.png" width="50"/> Gathering

다양한 모임에 참여해 취미와 관심사를 공유하고, 실시간으로 소통할 수 있는 채팅 기반 서비스

<img src="https://github.com/user-attachments/assets/943bc707-9aa5-41c8-834e-98186cde0054" width="200" /> | <img src="https://github.com/user-attachments/assets/27a649c0-99e4-4ff4-9237-a5224d011d7d" width="200" /> | <img src="https://github.com/user-attachments/assets/d6bbac02-39e2-4366-97c1-7c2405b4b33f" width="200" /> | <img src="https://github.com/user-attachments/assets/e4c756df-6ed1-4b87-90c4-05a7eaaddfcb" width="200" />
---|---| ---| ---|

## 프로젝트 환경
- 개발 인원: iOS 3명 Back-End 1명  
- 개발 기간: 24.11.01 ~ 24.12.17 (6주)  
- 최소 버전: iOS 16.0  

## 기술 스택
- 🎨 View Drawing: `SwiftUI`  
- 🏛️ Architecture: `TCA (The Composable Architecture)`  
- ♻️ Asynchronous: `Swift Concurrency`  
- 📡 Network: `Alamofire` `socketIO`  
- 📦 DB: `RealmSwift`  
- 🍎 Apple Framework: `PhotosUI`  
- 🎸 기타: `SwiftLint`  

## 주요 기능

- **회원가입, 로그인, 소셜 로그인** 기능
- 모임 **참여** 및 **생성**
- 모임 **둘러보기** 및 **검색**
- 모임 내 **그룹 채팅**
- **일대일 채팅**

## 협업 관리

### 브랜치 전략

- `Git Flow`에서 `release`, `hotfix` 브랜치를 제거한 형태로 사용
- 각 기능은 별도의 `feature` 브랜치에서 개발되고, `develop` 브랜치에서 통합하여 테스트
- 이로써 서로의 작업에 영향받지 않고 개발을 진행하며, 충돌 최소화 가능
- 안정적인 `main` 브랜치 유지: 검증된 코드만 `main` 브랜치에 병합 및 항상 배포 가능한 상태 유지

### Convention

- PR Template
- Issue Template 
- Commit Convention - `Karma Convention`
- Code Convention - `swiftLint`

## 주요 기술

### 단방향 데이터 흐름 아키텍처

- State가 Reducer를 통해서만 업데이트되고, View에서는 변경될 수 없도록 하여 `단방향 아키텍처 구현`
- 데이터 변경이 예측 가능, 상태변화를 추적하기 쉬움
- 각각의 요소가 독립적으로 동작하기에 확장성과 유지 보수가 용이하고 Testable 함
- 협업 시 일관적인 코드 스타일을 유지하기 위해 TCA를 적용
![image](https://hackmd.io/_uploads/Sk2VTHHS1l.png)

### TCA Navigation

- 트리 기반과 스택 기반 Navigation을 함께 활용한 내비게이션 구현
    - `tree-based`: 모달, 얼럿, 액션 시트 등의 pop-up 방식의 화면 전환에 활용
    - `stack-based`: NavigationStack을 통한 push-pop 방식의 화면 전환에 활용
  
### 실시간 채팅 구현

- DB, API, 소켓 순서로 Data 핸들링  
- 채팅 뷰 진입 시 DB에서 채팅 정보 Fetch  
- DB의 마지막 Date 기준으로 API 호출  
- 소켓 연결하여 Data 수신  
- DB에 저장된 데이터 기반으로 뷰에 표현  
- API 통신을 통해 채팅 전송  
   
### 소켓 통신

- OnAppear 시점에 소켓을 연결하고 OnDisappear 시점에 소켓 연결 해제  
- scenePhase를 사용하여 Background 진입 시 소켓 연결 해제, Active 진입 시 소켓 재연결  
- AsyncStream의 Continuation을 사용한 Data 전달  
- Generic을 활용하여 열거형으로 정의된 케이스에 따라 소켓 매니저 객체 재사용  
- Result 타입을 활용한 에러 핸들링  

### Database  

- 채팅방 모델(ChannelDBModel/DMRoomDBModel) 내에 멤버와 채팅 메시지를 리스트(List<> 구조)로 포함시켜 데이터를 효율적으로 저장 및 조회 가능  
- 데이터베이스 관련 로직을 Dependency로 분리하여 SRP를 준수하고, Reducer와의 결합도를 낮춤  

### 이미지 캐싱  

- NSCache를 사용한 메모리 캐싱  
    - 50MB 제한  
    - 이미지 API 통신 시 저장  
- FileManager를 사용한 디스크 캐싱  
    - 500MB 제한  
    - DB 저장 시 저장  
- 용량 제한 시 캐시 파일의 접근 시간을 기록하여 `LRU 전략을 통해 관리` 

### 토큰 갱신  

- 재귀 함수를 통해 토큰 갱신 성공 시 기존 네트워크 재호출  
- 동일한 StatusCode의 Error 응답을 Decoding하여 에러 핸들링  
- 토큰 갱신 실패 시 NotificationCenter를 통한 온보딩 뷰 전환  

### 채팅 UI  

- ScrollViewReader를 사용하여 채팅 뷰 진입 시와 채팅 갱신 시 자동으로 뷰를 맨 아래로 이동  
- 고정된 frame 값 대신 GeometryReader로 크기를 설정하여 `다양한 기기 대응`  
- 라인 제한에 따라 늘어나거나 스크롤되도록 Dynamic한 TextField 구현

### PhotoPicker

- PhotosPicker를 객체 생성 시 선택 가능 개수를 입력받을 수 있도록 커스텀하게 구현하여 여러 뷰에서 재사용 가능
- PhotosPicker에서 선택한 이미지를 UIImage로 변환하고 중복을 제거하여 Binding 된 selectedImages에 반영

### DTO 적용  

- API Response Model -> DB Model -> Present Model  
- Response Model을 DB나 뷰에 필요한 present model 데이터로 가공함으로 계층 간 의존성 최소화  
- API 모델을 순수하게 유지해서 API 변경 시 대응이 쉬움  
- 데이터의 단방향 흐름으로 각 계층 간의 책임이 명확해지고 디버깅이 용이  

### 기타  

- DisclosureGroup, Toolbar 등 기본 component를 래핑 하여 기능을 추가하고 재사용성을 높임 
- 로그아웃, 토큰 갱신 실패 시 NotificationCenter를 통한 RootView 상태 변화를 관리

## 트러블 슈팅

### 소켓 통신 데이터 연결

- 소켓을 통해 채팅 데이터가 들어올 때 Reducer에서 처리해주기 위해 completionHandler 사용
- 클로저 내에서 state의 값 변경과, action을 send할 수 없는 문제 발생
- AsyncStream을 사용해 소켓 이벤트를 스트림으로 처리함으로써 리듀서와 통합

### TCA Navigation 

- 기존의 화면전환은 트리 기반만을 사용
- 홈 -> 채널 채팅 -> 채널 세팅 형태로 연결된 화면 구성
- 기존 트리 기반의 `Destination` 으로 채널 세팅에서 홈으로 직접 이동하려면, 채널 세팅 상태와 채널 채팅 상태를 `단계적으로 nil로 만드는 상태 변경이 필요` 하여 구현이 복잡해짐
- 스택 기반의 `Path` 로 변경하여 채널 세팅에서 홈으로 바로 이동하는 경우, 단순히 `StackState를 비우는 방식으로 복잡한 로직을 명확하게 구현`

### DB 모델링

- 기존 DB 모델에서 채널 채팅과, DM 채팅에 속성으로 있는 멤버를 저장할 때 ObjectId로 새로 생성해 채팅마다 멤버를 저장하게 되어 중복 저장되는 경우가 발생
- 데이터 스키마 최적화를 통해 `데이터의 중복을 줄이고 참조를 통해 데이터 모델의 재사용성을 높임`
- DMRoomDBModel, ChannelDBModel에 List 형태의 members와 chattings 필드를 추가하여 데이터 그룹화 및 관리 용이

![스크린샷 2024-12-23 오전 2.37.15](https://hackmd.io/_uploads/HyWD0prSke.png)


## 회고

### Keep (좋았던 점)

- TCA 공식 문서가 학습 친화적으로 되어있어 배우기에 좋았음
- 소켓 통신을 활용한 실시간 채팅 구현 경험
- 네트워크, DB 등의 공통 모듈을 Dependency로 관리하여 의존성 분리
    
### Problem (아쉬웠던 점)

- 외부 라이브러리(TCA)에 대한 의존성 증가

### Try (시도할 점)

- 최초 채팅방 진입 시 시간 단축
