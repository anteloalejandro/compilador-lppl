// Ejemplo con errores lexicos y falta de "main": 3 errores
//---------------------------------------------------------
int principal ( )
{
  int  aAa123_2016;
  int c#;                   // caracter desconocido + error sintáctico

  aAa123_2016 = 3;
  c = (((aAa123_2016 / 2) + 3.56) - .34) * 2.;
  
  return 0;
}                           // el programa no tiene 'main'
