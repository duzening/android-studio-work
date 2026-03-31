void main(){
  int num1 = 10;
  double num2 = 3.141592;
  String num1Str = num1.toString();
  String num2Str = num2.toStringAsFixed(2);
  print("num1 to str is $num1Str");
  print("num2 to str is $num2Str");
  print("num1 to str is ${num1.toStringAsFixed(0)}");
  print("num2 to str is ${num2.toStringAsFixed(1)}");
}