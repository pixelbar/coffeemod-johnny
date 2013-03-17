(function() {
  var HIGH, LOW, StopProduce, board, bootloader, canmake, createSelection, eth_update, five, lcddefaults, led_Afwas, led_Koffie, led_Thee, led_WarmWater, liter, loopcount, nummer, quote, relais_lock, request, secret, select, selection, setLiters, setProgress, sleep, stopbutton, sw_10L, sw_25L, sw_50L, sw_75L, sw_Afwas, sw_Koffie, sw_Thee, sw_WarmWater, timeout, tosend;

  five = require("johnny-five");

  request = require('request');

  board = new five.Board();

  led_Koffie = 27;

  led_Thee = 26;

  led_WarmWater = 28;

  led_Afwas = 29;

  relais_lock = 31;

  sw_Koffie = 23;

  sw_Thee = 22;

  sw_WarmWater = 25;

  sw_Afwas = 24;

  sw_25L = 38;

  sw_50L = 41;

  sw_75L = 36;

  sw_10L = 39;

  stopbutton = 4;

  timeout = 10000;

  loopcount = 0;

  liter = 0;

  select = 0;

  nummer = 0;

  tosend = "";

  canmake = 0;

  secret = "";

  LOW = board.firmata.LOW;

  HIGH = board.firmata.HIGH;

  board.on('ready', function() {
    var lcd;
    this.pinMode(led_Koffie, OUTPUT);
    this.pinMode(led_Thee, OUTPUT);
    this.pinMode(led_WarmWater, OUTPUT);
    this.pinMode(led_Afwas, OUTPUT);
    this.pinMode(relais_lock, OUTPUT);
    this.pinMode(sw_Koffie, INPUT);
    this.pinMode(sw_Thee, INPUT);
    this.pinMode(sw_WarmWater, INPUT);
    this.pinMode(sw_Afwas, INPUT);
    this.pinMode(sw_25L, INPUT);
    this.pinMode(sw_50L, INPUT);
    this.pinMode(sw_75L, INPUT);
    this.pinMode(sw_10L, INPUT);
    this.digitalWrite(relais_lock, HIGH);
    lcd = new five.LCD({
      pins: [33, 30, 35, 32, 37, 34]
    });
    lcd.on("ready", function() {});
    bootloader();
    lcddefaults();
    return this.loop(50, function() {
      selection();
      sleep(10);
      loopcount++;
      if (loopcount === 6000) {
        quote();
      }
      if (loopcount(6500)) {
        lcddefaults();
      }
      if (loopcount === 12000) {
        loopcount = 0;
        return lcddefaults();
      }
    });
  });

  sleep = function(milliSeconds) {
    var startTime;
    startTime = new Date().getTime();
    while (new Date().getTime() < startTime + milliSeconds) {
      return;
    }
  };

  selection = function() {
    var start;
    canmake = 0;
    select = 0;
    if (this.digitalRead(sw_Koffie) === LOW) {
      createSelection(led_Koffie, "Koffie");
      select = 1;
    } else if (this.digitalRead(sw_Thee) === LOW) {
      createSelection(led_Thee, "Thee");
      select = 2;
    } else if (this.digitalRead(sw_WarmWater) === LOW) {
      createSelection(led_WarmWater, "Warm Water");
      select = 3;
    } else if (this.digitalRead(sw_Afwas) === LOW) {
      createSelection(led_Afwas, "Afwas Water");
      select = 4;
    }
    if (select > 0) {
      liter = 0;
      start = new Date().getTime();
      while (new Date().getTime() - start < timeout) {
        if (this.digitalRead(sw_25L) === LOW) {
          setLiters("2.5");
          liter = 1;
          start = 0;
        } else if (this.digitalRead(sw_50L) === LOW) {
          setLiters("5");
          liter = 2;
          start = 0;
        } else if (this.digitalRead(sw_75L) === LOW) {
          setLiters("7.5");
          liter = 3;
          start = 0;
        } else if (this.digitalRead(sw_10L) === LOW) {
          setLiters("10");
          liter = 4;
          start = 0;
        }
      }
    }
    if (liter > 0) {
      switch (liter) {
        case 1:
          setProgress(150000);
          break;
        case 2:
          setProgress(300000);
          break;
        case 3:
          setProgress(450000);
          break;
        case 4:
          setProgress(600000);
      }
    }
    this.digitalWrite(led_Koffie, LOW);
    this.digitalWrite(led_Thee, LOW);
    this.digitalWrite(led_WarmWater, LOW);
    this.digitalWrite(led_Afwas, LOW);
    this.digitalWrite(relais_lock, HIGH);
    return lcddefaults();
  };

  eth_update = function(must_delete) {
    if (must_delete) {
      return request("" + tosend + "/CoffeeCounter/remove.php?remove_id=" + secret);
    } else {
      return request("" + tosend + "/CoffeeCounter/index.php?Quantity=" + liter + "&Product=" + select + "&Token=1234567890", function(err, resp, body) {
        if (must_delete === false) {
          return secret = body;
        }
      });
    }
  };

  createSelection = function(led, type) {
    this.digitalWrite(led, HIGH);
    this.digitalWrite(relais_lock, LOW);
    return lcd.clear().setCursor(0, 0).print("/300  " + type + "  /300").setCursor(0.1).print("Selecteer Liters");
  };

  setLiters = function(amount) {
    return lcd.setCursor(0, 1).print(" " + amount + " Liter ");
  };

  setProgress = function(progress) {
    var i, _i, _j, _results;
    this.digitalWrite(relais_lock, HIGH);
    lcd.setCursor(0, 1).print("[              ]").setCursor(1, 1);
    for (i = _i = 1; _i <= 15; i = ++_i) {
      if (canmake === 0) {
        sleep(progress / 14);
        lcd.print("/003");
      }
    }
    eth_update(false);
    secret = "";
    _results = [];
    for (i = _j = 1; _j <= 5; i = ++_j) {
      lcd.setCursor(0, 1).print("/003   Bereiding  /003");
      sleep(200);
      lcd.setCursor(0, 1).print("/003   Voltooid   /003");
      _results.push(sleep(200));
    }
    return _results;
  };

  bootloader = function() {
    lcd.clear();
    lcd.setCursor(0, 0).print("    Illuzion    ");
    lcd.setCursor(0, 1).print("  Koffiezetter  ");
    sleep(1500);
    lcd.clear();
    lcd.setCursor(0, 0).print("    Made by :   ");
    lcd.setCursor(0, 1).print("   PiXeLBar  &  ");
    sleep(1000);
    lcd.setCursor(0, 1).print("    Bitlair     ");
    delay(1000);
    lcd.clear();
    lcd.setCursor(0, 0).print("  Please Enjoy  ");
    lcd.setCursor(0, 1).print("  Teh Coffeez!  ");
    sleep(800);
    lcd.clear();
    return sleep(500);
  };

  lcddefaults = function() {
    return lcd.clear().setCursor(0, 0).print("/003   PiXeLBar   /003").setCursor(0, 1).print(" Maak een keuze ");
  };

  quote = function() {
    var number;
    number = Math.floor(Math.random() * 10);
    switch (number) {
      case 0:
        return lcd.clear().setCursor(0, 0).print("Is het nog geen ").setCursor(0, 1).print(" tijd voor bier ");
      case 1:
        return lcd.clear().setCursor(0, 0).print("Lekker bakkie ? ").setCursor(0, 1).print("Of wil je thee ?");
      case 2:
        return lcd.clear().setCursor(0, 0).print(" Hiekie Faalt ! ").setCursor(0, 1).print(" FAAL FAAL FAAL ");
      case 3:
        lcd.clear().setCursor(0, 0).print("Live nyan feed :").setCursor(0, 1).print(" NYAN NYAN NYAN ");
        sleep(400);
        lcd.setCursor(0, 1).print("N NYAN NYAN NYAN");
        sleep(400);
        lcd.setCursor(0, 1).print("AN NYAN NYAN NYA");
        sleep(400);
        lcd.setCursor(0, 1).print("YAN NYAN NYAN NY");
        sleep(400);
        lcd.setCursor(0, 1).print("NYAN NYAN NYAN N");
        sleep(400);
        return lcd.setCursor(0, 1).print(" NYAN NYAN NYAN ");
      case 4:
        return lcd.clear().setCursor(0, 0).print("Als je dit leest").setCursor(0, 1).print(" Ik wil koffie! ");
      case 5:
        return lcd.clear().setCursor(0, 0).print(" Windows is kut ").setCursor(0, 1).print(" Ik wil LINUX!  ");
      case 6:
        return lcd.clear().setCursor(0, 0).print("Nu je hier toch ").setCursor(0, 1).print("bent,zet koffie!");
      case 7:
        lcd.clear().setCursor(0, 0).print("   Voor stats : ").setCursor(0, 1).print("koffie.illuzion.");
        sleep(400);
        lcd.setCursor(0, 1).print("offie.illuzion.l");
        sleep(400);
        lcd.setCursor(0, 1).print("ffie.illuzion.la");
        sleep(400);
        return lcd.setCursor(0, 1).print("fie.illuzion.lan");
      case 8:
        return lcd.clear().setCursor(0, 0).print(" Trolololololol ").setCursor(0, 1).print(" U iz Trolled!! ");
      case 9:
        return lcd.clear().setCursor(0, 0).print("Like this mod ? ").setCursor(0, 1).print("wiki.pixelbar.nl");
    }
  };

  StopProduce = function() {
    if (canmake === 0) {
      eth_update(true);
    }
    canmake = 1;
    this.digitalWrite(relais_lock, HIGH);
    lcd.clear().setCursor(0, 0).print(" What The FUCK! ").setCursor(0, 1).print("  Fatal FAAL!!  ");
    sleep(75000);
    lcd.clear().setCursor(0, 0).print("   Productie    ").setCursor(0, 1).print("  Geannuleerd   ");
    sleep(30000);
    return lcddefaults();
  };

}).call(this);
