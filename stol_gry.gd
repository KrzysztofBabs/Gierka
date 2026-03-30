extends Node2D

@onready var pole_gracza_1 = $kartyGracza
@onready var pole_gracza_2 = $kartyGraczaSplit 
@onready var pole_krupiera = $kartyKrupiera

@onready var tekst_punkty_1 = $punktyGracza 
@onready var tekst_punkty_2 = $punktyGraczaSplit 
@onready var tekst_punkty_krupiera = $punktyKrupiera

@onready var przycisk_dobierz = $dobierzKarte
@onready var przycisk_pass = $pass
@onready var przycisk_nowagra = $nowaGra
@onready var przycisk_podwoj = $podwoj
@onready var przycisk_split = $split 

@onready var tekst_kasa = $kasa
@onready var tekst_zaklad = $stawka
@onready var tekst_komunikat = $komunikat

@onready var kontener_zetonow = $kontenerZetonow
@onready var dzwiek_zetonu = $DzwiekZetonu
@onready var dzwiek_karty = $DzwiekKarty

var kasa = 1000
var zaklad_1 = 0
var zaklad_2 = 0 
var etap_obstawiania = true

var talia = []
var reka_gracza_1 = []
var reka_gracza_2 = [] 
var reka_krupiera = []

var czy_trwa_split = false
var aktywna_reka = 1
var wynik_koncowy_tekst = "" 

var kolory = ["Hearts", "Diamonds", "Clubs", "Spades"]
var figury = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]

func _ready():
	pole_gracza_2.visible = false
	tekst_punkty_2.visible = false
	tekst_komunikat.text = "Postaw 50$ i zacznij grę!"
	tekst_punkty_krupiera.text = "Krupier: ?"
	zablokuj_wszystkie_deczyje()
	aktualizuj_hajs()

func zablokuj_wszystkie_deczyje():
	przycisk_dobierz.disabled = true
	przycisk_pass.disabled = true
	przycisk_podwoj.disabled = true
	przycisk_split.disabled = true

func aktualizuj_hajs():
	tekst_kasa.text = "Kasa: " + str(kasa) + "$"
	if czy_trwa_split:
		tekst_zaklad.text = "Pula: " + str(zaklad_1 + zaklad_2) + "$ (Split)"
	else:
		tekst_zaklad.text = "Zakład: " + str(zaklad_1) + "$"

func _on_zeton_50_pressed():
	if not etap_obstawiania: return
	if zaklad_1 >= 200:
		tekst_komunikat.text = "Osiągnięto limit stołu (Max 200$)!"
		return
	
	if kasa >= 50:
		kasa -= 50
		zaklad_1 += 50
		aktualizuj_hajs()
		if dzwiek_zetonu:
			dzwiek_zetonu.play()
		
		var nowy_zeton = TextureRect.new()
		nowy_zeton.texture = load("res://Zeton50.png") 
		nowy_zeton.custom_minimum_size = Vector2(100, 100)
		nowy_zeton.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		nowy_zeton.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		kontener_zetonow.add_child(nowy_zeton)
		
		tekst_komunikat.text = "Obstawiono! Pula: " + str(zaklad_1) + "$"
	else:
		tekst_komunikat.text = "Brak gotówki!"

func _on_nowa_gra_pressed():
	if zaklad_1 == 0: 
		tekst_komunikat.text = "Najpierw postaw zakład!"
		return
		
	etap_obstawiania = false
	przycisk_nowagra.disabled = true
	pole_gracza_2.visible = false
	tekst_punkty_2.visible = false
	czy_trwa_split = false
	aktywna_reka = 1
	zaklad_2 = 0
	nowa_gra()

func nowa_gra():
	for pole in [pole_gracza_1, pole_gracza_2, pole_krupiera]:
		for karta_ui in pole.get_children():
			karta_ui.queue_free()
			
	generuj_talie()
	tasuj_talie()
	reka_gracza_1.clear()
	reka_gracza_2.clear()
	reka_krupiera.clear()
	
	rozdaj_karte(reka_gracza_1, pole_gracza_1)
	rozdaj_karte(reka_gracza_1, pole_gracza_1)
	rozdaj_karte(reka_krupiera, pole_krupiera)
	
	tekst_komunikat.text = "Twój ruch!"
	aktualizuj_teksty_punktow()
	sprawdz_startowe_opcje()

func aktualizuj_teksty_punktow():
	tekst_punkty_krupiera.text = "Krupier: " + str(policz_punkty(reka_krupiera))
	if czy_trwa_split:
		if aktywna_reka == 1:
			tekst_punkty_1.text = ">> Punkty: " + str(policz_punkty(reka_gracza_1)) + " <<"
			tekst_punkty_2.text = "Punkty: " + str(policz_punkty(reka_gracza_2))
		else:
			tekst_punkty_1.text = "Punkty: " + str(policz_punkty(reka_gracza_1))
			tekst_punkty_2.text = ">> Punkty: " + str(policz_punkty(reka_gracza_2)) + " <<"
	else:
		tekst_punkty_1.text = "Punkty: " + str(policz_punkty(reka_gracza_1))

func sprawdz_startowe_opcje():
	var punkty_gracza = policz_punkty(reka_gracza_1)
	if punkty_gracza == 21:
		tekst_komunikat.text = "Masz 21! Czekamy na krupiera..."
		zakoncz_runde_gracza()
		return
		
	przycisk_dobierz.disabled = false
	przycisk_pass.disabled = false
	if kasa >= zaklad_1: przycisk_podwoj.disabled = false
	
	if reka_gracza_1.size() == 2 and kasa >= zaklad_1:
		var p1 = reka_gracza_1[0]["punkty"]
		var p2 = reka_gracza_1[1]["punkty"]
		if p1 == p2:
			przycisk_split.disabled = false

func _on_split_pressed():
	if kasa >= zaklad_1:
		czy_trwa_split = true
		przycisk_split.disabled = true
		przycisk_podwoj.disabled = true 
		kasa -= zaklad_1
		zaklad_2 = zaklad_1
		aktualizuj_hajs()
		var ile_zetonow = int(zaklad_1 / 50)
		
		for i in range(ile_zetonow):
			var nowy_zeton = TextureRect.new()
			nowy_zeton.texture = load("res://Zeton50.png") 
			nowy_zeton.custom_minimum_size = Vector2(100, 100)
			nowy_zeton.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			nowy_zeton.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			kontener_zetonow.add_child(nowy_zeton)
		
		var karta = reka_gracza_1.pop_back()
		reka_gracza_2.append(karta)
		var img = pole_gracza_1.get_children().back()
		pole_gracza_1.remove_child(img)
		pole_gracza_2.add_child(img)
		
		pole_gracza_2.visible = true
		tekst_punkty_2.visible = true
		rozdaj_karte(reka_gracza_1, pole_gracza_1)
		rozdaj_karte(reka_gracza_2, pole_gracza_2)
		aktywna_reka = 1
		tekst_komunikat.text = "SPLIT! Ruch: Lewa Ręka"
		aktualizuj_teksty_punktow()
		sprawdz_punkty_aktywnej_reki()

func gracz_dobiera():
	przycisk_podwoj.disabled = true 
	if aktywna_reka == 1: rozdaj_karte(reka_gracza_1, pole_gracza_1)
	else: rozdaj_karte(reka_gracza_2, pole_gracza_2)
	aktualizuj_teksty_punktow()
	sprawdz_punkty_aktywnej_reki()

func sprawdz_punkty_aktywnej_reki():
	var punkty = policz_punkty(reka_gracza_1) if aktywna_reka == 1 else policz_punkty(reka_gracza_2)
	if punkty >= 21: gracz_czeka() 

func _on_pass_pressed(): gracz_czeka()

func gracz_czeka():
	if czy_trwa_split and aktywna_reka == 1:
		aktywna_reka = 2
		tekst_komunikat.text = "Ruch: Prawa Ręka"
		przycisk_podwoj.disabled = true
		aktualizuj_teksty_punktow()
		sprawdz_punkty_aktywnej_reki() 
	else:
		zakoncz_runde_gracza()

func zakoncz_runde_gracza():
	zablokuj_wszystkie_deczyje()
	var fura1 = policz_punkty(reka_gracza_1) > 21
	var fura2 = czy_trwa_split and policz_punkty(reka_gracza_2) > 21
	
	if fura1 and (fura2 or not czy_trwa_split):
		rozzlicz_gre()
	else:
		tura_krupiera()

func tura_krupiera():
	await get_tree().create_timer(0.8).timeout
	rozdaj_karte(reka_krupiera, pole_krupiera)
	aktualizuj_teksty_punktow()
	
	while policz_punkty(reka_krupiera) < 17:
		await get_tree().create_timer(1.0).timeout
		rozdaj_karte(reka_krupiera, pole_krupiera)
		aktualizuj_teksty_punktow()
		
	await get_tree().create_timer(1.0).timeout
	rozzlicz_gre()

func rozzlicz_gre():
	wynik_koncowy_tekst = ""
	var pk_krupiera = policz_punkty(reka_krupiera)
	
	rozlicz_jedna_reke(reka_gracza_1, zaklad_1, "Lewa", pk_krupiera)
	if czy_trwa_split:
		rozlicz_jedna_reke(reka_gracza_2, zaklad_2, "Prawa", pk_krupiera)
		
	tekst_komunikat.text = wynik_koncowy_tekst
	zaklad_1 = 0
	zaklad_2 = 0
	etap_obstawiania = true
	aktualizuj_hajs()
	przycisk_nowagra.disabled = false
	
	for zeton in kontener_zetonow.get_children():
		zeton.queue_free()

func rozlicz_jedna_reke(reka, stawka, nazwa, pkty_k):
	var pkty = policz_punkty(reka)
	var status = ""
	var bilans = 0 
	
	var gracz_ma_bj = (reka.size() == 2 and pkty == 21 and not czy_trwa_split)
	var krupier_ma_bj = (reka_krupiera.size() == 2 and pkty_k == 21)
	
	if gracz_ma_bj and krupier_ma_bj:
		status = "REMIS (Obaj BJ) - Zwrot " + str(stawka) + "$"
		kasa += stawka 
	elif gracz_ma_bj:
		bilans = int(stawka * 1.5)
		status = "BLACKJACK! Wygrana: +" + str(bilans) + "$"
		kasa += (stawka + bilans)
	elif krupier_ma_bj:
		status = "Dealer ma BJ! Przegrana: -" + str(stawka) + "$"
	elif pkty > 21:
		status = "FURA! Przegrana: -" + str(stawka) + "$"
	elif pkty_k > 21:
		status = "Krupier fura! Wygrana: +" + str(stawka) + "$"
		kasa += stawka * 2
	elif pkty > pkty_k:
		status = "WYGRANA! Zysk: +" + str(stawka) + "$"
		kasa += stawka * 2
	elif pkty == pkty_k:
		status = "REMIS - Zwrot " + str(stawka) + "$"
		kasa += stawka
	else:
		status = "PRZEGRANA: -" + str(stawka) + "$"
		
	if czy_trwa_split: wynik_koncowy_tekst += nazwa + ": " + status + "\n"
	else: wynik_koncowy_tekst = status

func _on_podwoj_pressed():
	if czy_trwa_split: return
	if kasa >= zaklad_1:
		var ile_zetonow = int(zaklad_1/50)
		kasa -= zaklad_1
		zaklad_1 *= 2
		aktualizuj_hajs()
		
		for i in range(ile_zetonow):
			var nowy_zeton = TextureRect.new()
			nowy_zeton.texture = load("res://Zeton50.png") 
			nowy_zeton.custom_minimum_size = Vector2(100, 100)
			nowy_zeton.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			nowy_zeton.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			kontener_zetonow.add_child(nowy_zeton)
		
		tekst_komunikat.text = "DOUBLE DOWN! Ostatnia karta..."
		zablokuj_wszystkie_deczyje()
		rozdaj_karte(reka_gracza_1, pole_gracza_1)
		aktualizuj_teksty_punktow()
		
		await get_tree().create_timer(0.8).timeout
		if policz_punkty(reka_gracza_1) > 21: rozzlicz_gre()
		else: tura_krupiera()

func generuj_talie():
	talia.clear()
	for kolor in kolory:
		for figura in figury:
			var pk = 11 if figura == "A" else (10 if figura in ["J", "Q", "K"] else int(figura))
			var img = "res://Cards/Card" + kolor + figura + ".png"
			talia.append({"figura": figura, "punkty": pk, "obrazek": img})

func tasuj_talie(): talia.shuffle()
			
func rozdaj_karte(reka, pole):
	if talia.size() > 0:
		var k = talia.pop_back()
		reka.append(k)
		var obraz = TextureRect.new()
		obraz.texture = load(k["obrazek"])
		obraz.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		obraz.texture_filter = TEXTURE_FILTER_NEAREST
		pole.add_child(obraz)
		if dzwiek_karty:
			dzwiek_karty.play()

func policz_punkty(reka):
	var suma = 0
	var asy = 0
	for k in reka:
		suma += k["punkty"]
		if k["figura"] == "A": asy += 1
	while suma > 21 and asy > 0:
		suma -= 10
		asy -= 1
	return suma
