# 🃏 Kasyno Blackjack (Godot 4)

W pełni grywalna symulacja klasycznej gry w oczko (Blackjack) stworzona w silniku **Godot Engine 4**. Projekt oferuje zaawansowane zasady kasynowe, interaktywny stół oraz pełną mechanikę obstawiania.

## 🎯 Główne funkcje
- **Pełna mechanika kart:** Rozdawanie, tasowanie, precyzyjne liczenie punktów (dynamiczna wartość Asów).
- **Zaawansowane ruchy gracza:**
  - **Dobierz / Pass** (Hit / Stand)
  - **Double Down** (Podwojenie stawki i dobór jednej karty)
  - **Split** (Rozdzielenie pary na dwie oddzielne ręce do rozgrywania)
- **Rozbudowana ekonomia:** Osobny portfel gracza, limity stołu, dynamicznie generowane wizualne stosy żetonów na stole.
- **Sztuczna Inteligencja Krupiera:** Automatyczne rozgrywanie tury z naturalnymi, czasowymi opóźnieniami (dobiera aż do minimum 17 punktów).
- **Oprawa Audio-Wizualna:** Grafiki HD kart, wizualizacja żetonów, dźwięki rozdawania kart oraz obstawiania.

## 🛠️ Technologie
- **Silnik:** Godot Engine 4.x
- **Język programowania:** GDScript


## 💡 Zasady gry
* Rozpocznij rundę klikając żeton w prawym dolnym rogu (każde kliknięcie zwiększa pulę o 50$).
* Wciśnij **Nowa Gra**, aby otrzymać karty.
* Pokonaj krupiera, uzyskując więcej punktów od niego, nie przekraczając jednak liczby 21 (Fura).
* Zgarnij bonus za trafienie Blackjacka (As + karta warta 10 punktów na start) ze wskaźnikiem wygranej 3:2!
