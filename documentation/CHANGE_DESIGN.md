# Stillwalks – Cambio de Diseño del Sistema de Esencia

## 1. Contexto y motivación

El sistema actual de Stillwalks genera Esencia principalmente cuando el usuario **no utiliza el móvil**, premiando el bienestar digital. Aunque esta idea es coherente con la filosofía del proyecto, durante las pruebas se ha detectado que:

* La generación pasiva resulta poco satisfactoria y difícil de percibir.
* El jugador siente poco control directo sobre su progreso económico.
* La experiencia dentro de casa es limitada.

Para solucionar esto, se propone una **reformulación del sistema de Esencia**, incorporando una capa de **juego incremental / clicker**, manteniendo intacta la parte diferencial de caminar y descubrir criaturas.

---

## 2. Objetivo del cambio

El objetivo es crear un sistema híbrido que:

* Aumente la implicación del jugador cuando abre la app.
* Mantenga el valor de caminar y no usar el móvil.
* Conecte la colección de criaturas con la economía.
* Permita una progresión clara, escalable y satisfactoria.

---

## 3. Nuevo loop principal del juego

### En casa (activo / semi-activo)

* El jugador **toca la pantalla** para generar Esencia.
* Compra **mejoras de Esencia** (clicker).
* Desbloquea producción automática.
* Gestiona mejoras, santuarios y orbes.

### En la calle (pasivo / físico)

* Caminar genera **Energía** (1 paso = 1 Energía).
* La Energía se usa para **canalizar orbes**.
* Los orbes desbloquean **criaturas**.
* Las criaturas aumentan la producción pasiva de Esencia.

👉 Ambos contextos se retroalimentan.

---

## 4. Nuevo sistema de generación de Esencia

La Esencia pasa a tener **tres fuentes principales**:

### 4.1 Generación activa (Tap)

* Cada toque en pantalla genera una cantidad base de Esencia.
* Esta cantidad puede mejorarse con multiplicadores.

Ejemplo:

* Base: 1 Esencia por tap
* Mejora x2, x3, etc.

---

### 4.2 Generación automática (Recolectores)

* Elementos comprables en la tienda.
* Generan Esencia por segundo sin interacción.
* Escalan con mejoras específicas.

Ejemplo:

* Recolector Básico: +1 Esencia / segundo
* Recolector Avanzado: +5 Esencia / segundo

---

### 4.3 Generación pasiva por criaturas (NOVEDAD CLAVE)

Cada criatura registrada en el **Diario del Explorador** genera Esencia pasiva de forma permanente.

#### Producción por rareza (propuesta):

* Común: +0.02 Esencia / segundo
* Poco común: +0.05 Esencia / segundo
* Rara: +0.10 Esencia / segundo
* Épica: +0.25 Esencia / segundo
* Legendaria: +0.50 Esencia / segundo
* Mítica: 0 (valor narrativo / especial)

👉 La producción se **suma**, no se multiplica.

---

## 5. Reglas de balance (muy importantes)

Para evitar romper la economía:

* La Esencia de criaturas **no se ve afectada** por multiplicadores de tap.
* No hay sinergias exponenciales entre criaturas.
* Las criaturas aportan una base estable y lenta.
* El crecimiento fuerte sigue viniendo de mejoras compradas.

---

## 6. Relación con el sistema de criaturas

### Descubrimiento

* Cada nueva criatura aumenta la producción pasiva total.
* El Diario del Explorador deja de ser solo coleccionismo.

### Evolución

* Al evolucionar, una criatura puede:

  * Aumentar ligeramente su producción pasiva.
  * Mantener la misma (según balance).

Ejemplo:

* Criatura Rara base: +0.10/s
* Evolución: +0.15/s

---

## 7. Producción offline (clásico de clickers)

Cuando el jugador vuelve a abrir la app:

* Se calcula el tiempo offline.
* Se otorga un **porcentaje** de la Esencia que se habría generado automáticamente.

Ejemplo:

* Offline efficiency: 50%
* 1 hora fuera → recibe 30 minutos de producción

Esto:

* Evita castigar al jugador
* No premia dejar el juego indefinidamente

---

## 8. Tienda y progresión del sistema Clicker (Esencia)

Esta sección define **exclusivamente** la economía, tienda y progresión del sistema clicker de Esencia, independiente del walking loop.

### 8.1 Objetivos de progresión

* Early game muy activo y satisfactorio (mucho tap)
* Transición clara hacia automatización
* Mid game centrado en optimización
* Late game estable, sin romper la economía

La progresión sigue una curva **cuasi-exponencial controlada** (costes suben más rápido que la producción).

---

## 8.2 Generación de Esencia

La Esencia se genera a través de **fuentes acumulativas y escalables**, siguiendo un modelo clásico de clicker (inspiración tipo Cookie Clicker).

Fuentes:

* Tap manual (mejorable)
* Edificios productores (comprables y mejorables)
* Multiplicadores globales
* Criaturas descubiertas
* Producción offline (limitada)

---

## 8.3 Tienda Clicker – Estructura General

La tienda de Esencia se divide en **4 pilares** claros:

1. Tap manual
2. Edificios productores de Esencia
3. Multiplicadores globales
4. Sinergias de criaturas

Cada pilar progresa de forma independiente, pero se potencia entre sí.

---

## 8.4 Tap Manual

El tap es la primera fuente de Esencia y nunca pierde utilidad.

| Mejora         | Efecto              | Coste inicial | Escalado |
| -------------- | ------------------- | ------------- | -------- |
| Fuerza de Tap  | +1 Esencia por tap  | 25            | x1.5     |
| Ritmo Interior | +10% taps efectivos | 100           | x1.6     |

Notas:

* No tiene hard cap
* A partir de mid-game es complementario

---

## 8.5 Edificios Productores de Esencia

Los edificios son **fuentes pasivas permanentes**. Cada tipo:

* Se compra por primera vez (desbloqueo)
* Puede comprarse varias veces
* Cada edificio tiene su propio nivel

El número máximo de edificios de cada tipo puede depender del **nivel de explorador**.

### Tipos de Edificios

| Edificio         | Producción base | Coste inicial | Escalado |
| ---------------- | --------------- | ------------- | -------- |
| Recolector       | 1 / seg         | 100           | x1.7     |
| Mina             | 5 / seg         | 750           | x1.8     |
| Cantera          | 20 / seg        | 4.000         | x1.9     |
| Yacimiento       | 75 / seg        | 15.000        | x2.0     |
| Fábrica Esencial | 250 / seg       | 75.000        | x2.1     |

### Mejora de Edificios

Cada edificio tiene niveles que:

* Aumentan su producción base
* Aplican multiplicadores internos

Ejemplo:

* Nivel 1: producción base
* Nivel 5: +50% producción
* Nivel 10: x2 producción

---

## 8.6 Multiplicadores Globales

Afectan a **toda la producción de Esencia**.

| Mejora         | Efecto                 | Coste inicial | Escalado |
| -------------- | ---------------------- | ------------- | -------- |
| Flujo Esencial | x1.2 esencia total     | 2.000         | x2.5     |
| Catalizador    | +20% producción pasiva | 4.500         | x2.3     |

Hard cap recomendado: x3.0 acumulado

---

## 8.7 Sinergias de Criaturas

Cada criatura descubierta aporta Esencia pasiva.

| Rareza     | Esencia / min         |
| ---------- | --------------------- |
| Común      | 1                     |
| Poco común | 2                     |
| Rara       | 5                     |
| Épica      | 10                    |
| Legendaria | 25                    |
| Mítica     | No genera (exclusiva) |

Mejoras asociadas:

| Mejora            | Efecto                     | Coste inicial |
| ----------------- | -------------------------- | ------------- |
| Afinidad Esencial | +10% esencia por criaturas | 1.000         |
| Resonancia Viva   | +1 esencia/min a todas     | 3.500         |

---

## 8.8 Producción Offline

| Mejora          | Efecto                 | Coste  |
| --------------- | ---------------------- | ------ |
| Eco Persistente | 25% producción offline | 2.000  |
| Memoria Vital   | 50% producción offline | 6.000  |
| Latido Silente  | 75% producción offline | 15.000 |

Reglas:

* Máx 8h offline
* Nunca supera la producción online

---

## 8.9 Principios de Balance

* Cada edificio tiene identidad clara

* Más edificios ≠ mejor sin multiplicadores

* La progresión es visible y satisfactoria

* El tap siempre suma

* La colección de criaturas siempre aporta valor

* Ninguna mejora es obligatoria

* Todo suma, nada rompe

* El tap nunca es inútil

* La colección siempre recompensa

* El walking loop sigue siendo cuello de botella
---

## 9. Beneficios del nuevo sistema

* Mayor sensación de control y progreso.
* El jugador siempre siente que avanza.
* Caminar sigue siendo esencial.
* La colección tiene impacto real.
* Stillwalks se diferencia de otros incrementales.

---

## 10. Conclusión

Este cambio transforma Stillwalks en un **incremental híbrido** donde:

* Jugar en casa genera Esencia.
* Caminar desbloquea criaturas.
* Las criaturas alimentan la economía.

El resultado es un sistema coherente, escalable y alineado con la identidad del proyecto.

Este sistema convierte la Esencia en un **meta-juego completo**, divertido en casa y coherente con el loop de exploración exterior.
