void main1(){
  int a = 10;
  int b = 3;
  print("${a + b}");
  print("${a / b}");
}

void main2(){
  int a = 10 ;
  a += 5;
  print("$a");
}

void main3(){
  int c = 5 ;
  print("${c++}");
  print("${++c}");
}

void main4(){
  int x = 7;
  int y = 10 ;
  print("${x > y }");
  print("${x <= y }");
  print("${x == y }");
}

void main5 (){
  bool isRaining = false;
  bool hasUmbrella = true;
  bool chumen = !isRaining || hasUmbrella;
  print("$chumen");
}

void main6 (){
  int p = 6;
  int q = 3;
  print("${p & q}");
  print("${p | q}");
}

void main7 (){
  int p = 6;
  print("${p << 1}");
  print("${p >> 1}");
}

void main8 (){
  int age = 18;
  String result = age > 20 ? "chengnian" : "qingshaonian ";
      print("$result");
}

void main9 (){
  Object a = 'hello';
  if (a is String){
    print("zifuchuan");
  }
  if (a is num){
    print("shuzi");
  }
  String b = a as String;
  print(b.toUpperCase());
}