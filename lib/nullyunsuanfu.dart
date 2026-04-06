import 'dart:io';

int? getLength(String? value) {
  return value?.length;
}

void main(){
  String? name;
  print(name ?? "1111");
  name ??= "123";
  print(name);

  String? text;
  print(text?.length);
  print(getLength(text));

  print("aaaaaaa");
  String? input = stdin.readLineSync();
  print(input ?? 'bbb');
  print(input?.length);
  if(input != null) {
    int len = input.length;
    print('daaaaa: $len');
  }else{
    print('nulladassdasdasd');
  }
}