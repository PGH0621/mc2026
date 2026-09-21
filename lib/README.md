이 폴더에는 직접 만든 라이브러리를 둡니다.

  lib/
    MyServo/
      MyServo.h
      MyServo.cpp

외부 공개 라이브러리는 여기에 복사하지 말고 platformio.ini 의 lib_deps 에 버전과 함께 적으세요.
(그래야 Windows/macOS 모두 같은 버전을 내려받습니다)
