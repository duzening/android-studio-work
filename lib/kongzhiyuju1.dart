import 'dart:io';
void main (){
  List<String> colors = ['Yellow', 'Red', 'Blue'];
  for (int i = 0; i < colors.length; i++){
    print(colors[i]);
  }
  int i = 0;
  while (i < colors.length) {
    print(colors[i]);
    i++;
  }
  int j = 3;
  do {
    print(j);
    j--;
  } while (j > 0);
}