:- dynamic(hesap/5).
% Veritabanı

%banka(bankakod, isim)
%hesap(hesapno,bankakod,iban,musterino,bakiye)
%musteri(musterino, tcno, ad, soyad, cinsiyet)


banka(1, 'Ziraat').
banka(2, 'Garanti').

musteri(1, '12345678901', 'Ahmet', 'Yılmaz', 'Erkek').
musteri(2, '23456789012', 'Ayşe', 'Kaya', 'Kadın').

hesap(101, 1, 'TR010001000100101010101010', 1, 5000000).
hesap(102, 1, 'TR010001000100101010101011', 2, 3000).
hesap(201, 2, 'TR020002000200202020202020', 1, 7000).

% EFT işlemi
eft(YapanHesapNo, AliciIban, Miktar, Mesaj) :-
    hesap(YapanHesapNo, YapanBankaKod, YapanIban, _, Bakiye),
    hesap(AliciHesapNo, AliciBankaKod, AliciIban, _, AliciBakiye),
    AliciIban \= YapanIban, % Aynı hesap arası EFT olmamalı
    AliciBankaKod \= YapanBankaKod,
    Bakiye >= Miktar, % Yeterli bakiye kontrolü
    YeniBakiye is Bakiye - Miktar,
    YeniBakiyeAlici is AliciBakiye + Miktar,
    retractall(hesap(YapanHesapNo, BankaKod, YapanIban, _, _)),
    retractall(hesap(AliciHesapNo, BankaKod, AliciIban, _, _)),
    assertz(hesap(YapanHesapNo, BankaKod, YapanIban, _, YeniBakiye)),
    assertz(hesap(AliciHesapNo, BankaKod, AliciIban, _, YeniBakiyeAlici)),
    Mesaj = 'EFT işlemi başarılı!'.
    

% Havale işlemi
havale(YapanHesapNo, AliciHesapNo, Miktar, Mesaj) :-
    hesap(YapanHesapNo, BankaKod, YapanIban, _, Bakiye),
    hesap(AliciHesapNo, BankaKod, AliciIban, _, AliciBakiye), % AliciBakiye tanımlanıyor
    YapanHesapNo \= AliciHesapNo,
    Bakiye >= Miktar,
    Miktar > 0,
    YeniBakiye is Bakiye - Miktar,
    YeniBakiyeAlici is AliciBakiye + Miktar,
    retractall(hesap(YapanHesapNo, BankaKod, YapanIban, _, _)),
    retractall(hesap(AliciHesapNo, BankaKod, AliciIban, _, _)),
    assertz(hesap(YapanHesapNo, BankaKod, YapanIban, _, YeniBakiye)),
    assertz(hesap(AliciHesapNo, BankaKod, AliciIban, _, YeniBakiyeAlici)),
    Mesaj = 'Havale işlemi başarılı!'.

% Kullanıcıdan işlem türü ve bilgileri alarak işlemi gerçekleştir
start :-
    write('Yapmak istediğiniz işlemi tuşlayınız? (1: EFT, 2: Havale)'),
    read(Type),
    process(Type).



% Chatbot

% İşlem türüne göre işlem yap
process(1) :- % EFT
    write('Gönderen Hesap No: '),
    read(YapanHesapNo),
    write('Alıcı IBAN: '),
    read(AliciIban),
    write('Miktar: '),
    read(Miktar),
    (   writeln('EFT işlemi kontrol ediliyor...'),
        eft(YapanHesapNo, AliciIban, Miktar, _),
        writeln('EFT işlemi başarıyla gerçekleştirildi.') ; writeln('EFT işlemi başarısız. Lütfen tekrar deneyiniz.')
    ).

process(2) :- % Havale
    write('Gönderen Hesap No: '),
    read(YapanHesapNo),
    write('Alıcı Hesap No: '),
    read(AliciHesapNo),
    write('Miktar: '),
    read(Miktar),
    (   writeln('Havale işlemi kontrol ediliyor...'),
        havale(YapanHesapNo, AliciHesapNo, Miktar, _),
        writeln('Havale işlemi başarıyla gerçekleştirildi.') ; writeln('Havale işlemi başarısız. Lütfen tekrar deneyiniz.')
    ).

process(_) :-
    write('Geçersiz işlem türü.').




% Chatbot işlevleri
handle_input(Eylem, Cevap) :-
    (
        Eylem = eft(YapanHesapNo, AliciIban, Miktar) ->
        eft(YapanHesapNo, AliciIban, Miktar, Mesaj),
        Cevap = Mesaj
    ;
        Eylem = havale(YapanHesapNo, AliciHesapNo, Miktar) ->
        havale(YapanHesapNo, AliciHesapNo, Miktar, Mesaj),
        Cevap = Mesaj
    ;
        Cevap = 'Anlaşılmadı, lütfen tekrar deneyin.'
    ).

% Test sorgusu
test_sorgusu :-
    handle_input(eft(101, 'TR020002000200202020202020', 2000), Cevap),
    writeln(Cevap).

:- initialization(start).








