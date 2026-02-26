# Syntax Directed Translation with Jison

Esta práctica tiene como objetico familiarizaronos con la traducción dirigida por la sintaxis, así como con flex y jest.

Los objetivos son los siguientes:

1. Configurar las dependencias y generar el parser.
2. Profundizar sobre la especificación del analizador en JISON, respondiendo una serie de preguntas.
3. Modificar el analizador léxico para tratar los comentarios.
4. Modificar el analizador léxico para números en punto flotante.
5. Añadir pruebas para el analizador.

## Preguntas

### Describa la diferencia entre /* skip whitespace */ y devolver un token

La diferencia es que el ```/* skip whitespaces */``` no devuelve nada, solo ignora espacios, tabs, saltos de línea. Es invisible para el parser, solo sirve para ignorar símbolos, en este caso, 'whitespaces'.

### Escriba la secuencia exacta de tokens producidos para la entrada 123**45+@.

La secuencia producida es: NUMBER, OP, NUMBER, OP, INVALID

### Indique por qué ** debe aparecer antes.

Porque el lexer evalúa las reglas en orden: si pusieras ```[-+*/]``` primero, el ```**``` se rompería en dos ```*``` individuales, no en un operador de potencia.
El orden importa, primero se deben poner los patrones más específicos y luego los generales.

### Explique cuándo se devuelve EOF.

```<<EOF>>``` se devuelve cuando el lexer llega al final de la entrada. Es un token especial que indica el final del fichero/entrada.

### Explique por qué existe la regla . que devuelve INVALID.

Esta es una regla que abarca cualquier caracter que no coincida con las reglas anteriores, lo cuál significaría que ese carácter no es válido.

## Modificaciones grammar.jison

Las definiciones regulares finales son las siguientes:
```
\/\/[^\n]*             { /* skip single-line comments */; }
\s+                   { /* skip whitespace */; }
[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?   { return 'NUMBER'; }  // enteros, decimales y científicos
"**"                  { return 'OP';           }
[-+*/]                { return 'OP';           }
<<EOF>>               { return 'EOF';          }
.                     { return 'INVALID';      }
```

## Modificaciones tests

Se han añadido los siguientes test:
```

```