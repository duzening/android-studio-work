import 'dart:io';
void main (){
  print('pelase enter a number:');

  String? input = stdin.readLineSync();
  int number = int.parse(input!);

  if (number > 0 ){
   print('$number : dayu0');
  }else if(number < 0){
    print('$number : xiaoyu0');
  }else {
    print('$number : 0');
  }
}