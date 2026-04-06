import 'dart:io';

void main(){
  String? nickname;
  late String displayName;
  print("please enter your name:");
  nickname = stdin.readLineSync();
  if (nickname == null || nickname.isEmpty) {
    displayName = 'guest';
  }
    else{
      displayName = nickname;
  }
    print("your id is : $displayName");
}