void main(){
  List<int> statusCodes = [100, 200, 301, 301, 999];
  for (int code in statusCodes){
    switch(code){
      case 100:
        print('$code : OPEN');
        break;
      case 200:
        print('$code : APPREVED');
        break;
      case 301:
        print('$code : DENIEN with error');
        break;
      case 302:
        print('$code : DENIEN with error');
        break;
      case 999:
        print('$code : unknow status');
        break;
    }
  }
}