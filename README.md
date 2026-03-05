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
describe('Comments handling', () => {
  test('should ignore single-line comments', () => {
    expect(parse("3 + 5 // this is a comment")).toBe(8);
    expect(parse("10 - 2 // subtract")).toBe(8);
    expect(parse("// entire line comment\n7 * 2")).toBe(14);
    expect(parse("1 + 2 // comment\n + 3")).toBe(6);
  });
});

describe('Floating point and scientific numbers', () => {
  test('should parse decimal numbers', () => {
    expect(parse("2.35 + 0.65")).toBeCloseTo(3.0);
    expect(parse("0.1 + 0.2")).toBeCloseTo(0.3);
  });

  test('should parse numbers in scientific notation', () => {
    expect(parse("2.35e3 + 1")).toBeCloseTo(2351);
    expect(parse("1.2E2 + 3")).toBeCloseTo(123);
    expect(parse("5e-1 + 0.25")).toBeCloseTo(0.75);
    expect(parse("3.5e+2 - 50")).toBeCloseTo(300);
  });

  test('should mix integers, decimals, and scientific numbers', () => {
    expect(parse("10 + 2.5 + 1e1")).toBeCloseTo(22.5);
    expect(parse("1 + 2.0e2 + 3.5")).toBeCloseTo(204.5);
  });
});
```

## Preguntas parte 2

Para las siguientes frases: 4.0-2.0*3.0, 2\*\*3\*\*2 y 7-4/2:

### Escriba la derivación para cada una de las frases.

Frase: 4.0-2.0*3.0

L
⇒ E eof
⇒ E op T eof
⇒ E op T op T eof
⇒ T op T op T eof
⇒ number op T op T eof
⇒ 4.0 op T op T eof
⇒ 4.0 - T op T eof
⇒ 4.0 - number op T eof
⇒ 4.0 - 2.0 op T eof
⇒ 4.0 - 2.0 * T eof
⇒ 4.0 - 2.0 * number eof
⇒ 4.0 - 2.0 * 3.0 eof

Frase: 2\*\*3\*\*2

L
⇒ E eof
⇒ E op T eof
⇒ E op T op T eof
⇒ T op T op T eof
⇒ number op T op T eof
⇒ 2 op T op T eof
⇒ 2 ** T op T eof
⇒ 2 ** number op T eof
⇒ 2 ** 3 op T eof
⇒ 2 ** 3 ** T eof
⇒ 2 ** 3 ** number eof
⇒ 2 ** 3 ** 2 eof

Frase: 7-4/2

L
⇒ E eof
⇒ E op T eof
⇒ E op T op T eof
⇒ T op T op T eof
⇒ number op T op T eof
⇒ 7 op T op T eof
⇒ 7 - T op T eof
⇒ 7 - number op T eof
⇒ 7 - 4 op T eof
⇒ 7 - 4 / T eof
⇒ 7 - 4 / number eof
⇒ 7 - 4 / 2 eof

### Escriba el árbol de análisis sintáctico (parse tree) para cada una de las frases.

Frase: 4.0-2.0*3.0

            E
         /  |   \
        E   op    T
      / | \        |
     E  op  T      number(3.0)
     |      |
     T      number(2.0)
     |
 number(4.0)

Se interpreta como (4.0 - 2.0) * 3.0, no comor 4.0 - (2.0 * 3.0)

Frase: 232

            E
         /  |   \
        E   op    T
      / | \        |
     E  op  T      number(2)
     |      |
     T      number(3)
     |
 number(2)

Se interpreta como (2 ** 3) ** 2, no como 2 ** (3 ** 2)

Frase: 7-4/2

            E
         /  |   \
        E   op    T
      / | \        |
     E  op  T      number(2)
     |      |
     T      number(4)
     |
 number(7)

Se interpreta como (7 - 4) / 2, no como 7 - (4 / 2)

### ¿En qué orden se evaluan las acciones semánticas para cada una de las frases?

Frase: 4.0-2.0*3.0

Debido a la recursión izquierda, las acciones se evalúan de abajo hacia arriba:

convert("4.0")
convert("2.0")
operate('-', 4.0, 2.0) → 2.0
convert("3.0")
operate('*', 2.0, 3.0) → 6.0
Resultado final: 6.0

Incorrecto, según las matemáticas debería dar -2.0

Frase: 232

Debido a la recursión izquierda, las acciones se evalúan de abajo hacia arriba:

convert("2")
convert("3")
operate('', 2, 3) → 8
convert("2")
operate('', 8, 2) → 64

Resultado final: 64

Incorrecto, según las matemáticas debería dar 512

Frase: 7-4/2

Debido a la recursión izquierda, las acciones se evalúan de abajo hacia arriba:

convert("7")
convert("4")
operate('-', 7, 4) → 3
convert("2")
operate('/', 3, 2) → 1.5

Resultado final: 1.5

Incorrecto, según las matemáticas debería dar 5

## Modificación gramática

Para respetar la precedencia y la asociatividad de los operadores matemáticos ha sido necesario reestructurar la gramática original. En la versión inicial, todas las operaciones se definían en una única producción E → E op T, lo que provocaba que todos los operadores tuviesen la misma precedencia y que además fueran asociativos por la izquierda debido a la recursión izquierda. Como consecuencia, expresiones como 4.0-2.0*3.0 o 2\*\*3\*\*2 no se evaluaban siguiendo las reglas matemáticas habituales.

La modificación principal ha consistido en introducir niveles jerárquicos en la gramática, separando los operadores según su precedencia. Para ello se han añadido los no terminales E, T, R y F, cada uno representando un nivel distinto de prioridad. El no terminal E gestiona los operadores aditivos (+ y -), T los operadores multiplicativos (* y /), R el operador de potencia (**), y F los operandos numéricos. Esta estructuración garantiza que primero se reduzcan las potencias, después las multiplicaciones y divisiones, y finalmente las sumas y restas.

Además, se han dividido los tokens en tres tipos diferentes: OPAD para los operadores aditivos, OPMU para los multiplicativos y OPOW para la potencia. Esta separación permite que cada producción aplique la operación correspondiente únicamente en su nivel de precedencia, evitando ambigüedades.

Otro cambio importante ha sido la forma de definir la potencia. Mientras que la suma, resta, multiplicación y división se han mantenido como recursivas por la izquierda (lo que garantiza asociatividad por la izquierda), la potencia se ha definido mediante recursión por la derecha (R → F OPOW R). Esto asegura que el operador de potencia sea asociativo por la derecha, como establecen las matemáticas, de modo que una expresión como 2\*\*3\*\*2 se interprete correctamente como 2**(3**2).

## Tests para la modificación

Los tests añadidos son los siguientes:

```javascript
describe("Precedencia y asociatividad con flotantes", () => {
  test("Precedencia multiplicativa sobre aditiva", () => {
    expect(parser.parse("4.0-2.0*3.0")).toBeCloseTo(-2.0); // 4.0 - (2.0 * 3.0) = -2.0
  });

  test("Precedencia multiplicativa sobre aditiva (división)", () => {
    expect(parser.parse("7.0-4.0/2.0")).toBeCloseTo(5.0); // 7.0 - (4.0 / 2.0) = 5.0
  });

  test("Asociatividad izquierda en suma", () => {
    expect(parser.parse("5.0-2.0-1.0")).toBeCloseTo(2.0); // (5.0 - 2.0) - 1.0 = 2.0
  });

  test("Asociatividad izquierda en multiplicación", () => {
    expect(parser.parse("8.0/2.0/2.0")).toBeCloseTo(2.0); // (8.0 / 2.0) / 2.0 = 2.0
  });

  test("Precedencia de potencia sobre multiplicación", () => {
    expect(parser.parse("2.0*3.0**2.0")).toBeCloseTo(18.0); // 2.0 * (3.0 ** 2.0) = 18.0
  });

  test("Asociatividad derecha en potencia", () => {
    expect(parser.parse("2.0**3.0**2.0")).toBeCloseTo(512.0); // 2.0 ** (3.0 ** 2.0) = 512.0
  });
});
```