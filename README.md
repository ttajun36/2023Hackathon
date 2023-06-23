# 밥 먹을래요?
게시판과 채팅방을 이용하여 밥 약속을 잡을 수 있는 어플

## 프로젝트 소개
인스타그램과 당근마켓을 참고하여 만든 어플입니다.
Flutter, Firebase 사용.

## 개발 기간
  22. 04. 28 ~ 22. 04. 30

## 페이지 소개
#### 로그인, 회원가입
<p align="center">
  <img src="https://user-images.githubusercontent.com/31652115/248213470-2f35a72e-d2a6-44ce-bd4b-57f6063df775.PNG">
</p>

#### 게시판 - home
<p align="center">
  <img src="https://user-images.githubusercontent.com/31652115/248213500-b70dcf18-1bbf-4556-806e-9c780cebe89f.PNG">
</p>

#### 채팅방 - chats
<p align="center">
  <img src="https://user-images.githubusercontent.com/31652115/248213525-14be36b0-a31f-4015-8637-17f7cafff0f5.PNG">
</p>

#### 프로필 - profile
각 항목은 탭을 통해 내용 수정 가능
<p align="center">
  <img src="https://user-images.githubusercontent.com/31652115/248213830-c6e6f9a5-8523-4b04-a8ff-a727f5c420e7.PNG">
</p>

## 사용 기술
- Firebase authentication을 통해 로그인, 회원가입 이용
- Firebase - storage에 이미지 저장
- Firebase - firestore databases에 users, posts, chats 컬렉션을 통해 DB관리
    posts 컬렉션 내 comments 컬렉션을 통해 밥 약속 참여 인원 관리
    chats 컬렉션 내 realchats 컬렉션을 통해 채팅 구현
