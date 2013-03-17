five            = require("johnny-five")
request         = require('request')

board           = new five.Board()

led_Koffie      = 27
led_Thee        = 26
led_WarmWater   = 28
led_Afwas       = 29

relais_lock     = 31

sw_Koffie       = 23
sw_Thee         = 22
sw_WarmWater    = 25
sw_Afwas        = 24
sw_25L          = 38
sw_50L          = 41
sw_75L          = 36
sw_10L          = 39
stopbutton      = 4

timeout         = 10000


loopcount       = 0
liter           = 0
select          = 0
nummer          = 0
tosend          = ""
canmake         = 0
secret          = ""

LOW             = board.firmata.LOW
HIGH            = board.firmata.HIGH


board.on 'ready', ->

  # Ethernet.begin(mac, ip, subnet);
  # delay(1000);

  @pinMode(led_Koffie, OUTPUT)
  @pinMode(led_Thee, OUTPUT)
  @pinMode(led_WarmWater, OUTPUT)
  @pinMode(led_Afwas, OUTPUT)
  @pinMode(relais_lock, OUTPUT)

  @pinMode(sw_Koffie, INPUT)
  @pinMode(sw_Thee, INPUT)
  @pinMode(sw_WarmWater, INPUT)
  @pinMode(sw_Afwas, INPUT)
  @pinMode(sw_25L, INPUT)
  @pinMode(sw_50L, INPUT)
  @pinMode(sw_75L, INPUT)
  @pinMode(sw_10L, INPUT)
  
  # attachInterrupt(stopbutton, StopProduce, LOW);
  # interrupts();

  @digitalWrite(relais_lock, HIGH)

  lcd = new five.LCD(pins: [33, 30, 35, 32, 37 ,34])
  
  lcd.on "ready", ->
    
    # TODO:
    # - herschrijf het onderstaande stuk originele code

    # VOORBEELD:
    # # creates a heart!
    # lcd.createChar 0x07, [0x00, 0x0a, 0x1f, 0x1f, 0x0e, 0x04, 0x00, 0x00]
    
    # # Line 1: Hi rmurphey & hgstrp!
    # lcd.clear().print "rmurphey, hgstrp"
    # lcd.setCursor 0, 1
    
    # # Line 2: I <3 johnny-five
    # lcd.print("I ").write(7).print " johnny-five"

    # @repl.inject lcd: lcd

    # ORIGINELE CODE:
    # //  Define Coffeecup
    # lcd.createChar(3, cup);
    
    # // Start LCD
    # lcd.begin(16, 2);


  # Start bootloader
  bootloader()

  # Set LCD to Defaults
  lcddefaults()

  @loop 50, ->
    selection()

    sleep(10)
    loopcount++

    quote() if loopcount is 6000
    lcddefaults() if loopcount 6500

    if loopcount is 12000
      loopcount = 0
      lcddefaults()


sleep = (milliSeconds) ->
  startTime = new Date().getTime()
  return while(new Date().getTime() < startTime + milliSeconds)

selection = ->
  canmake = 0
  select  = 0

  if @digitalRead(sw_Koffie) is LOW
    createSelection(led_Koffie, "Koffie")
    select = 1
  else if @digitalRead(sw_Thee) is LOW
    createSelection(led_Thee, "Thee")
    select = 2
  else if @digitalRead(sw_WarmWater) is LOW
    createSelection(led_WarmWater, "Warm Water")
    select = 3
  else if @digitalRead(sw_Afwas) is LOW
    createSelection(led_Afwas, "Afwas Water")
    select = 4

  if select > 0
    liter = 0
    start = new Date().getTime()
    while(new Date().getTime()-start < timeout)
      if @digitalRead(sw_25L) is LOW
        setLiters("2.5")
        liter = 1
        start = 0
      else if @digitalRead(sw_50L) is LOW
        setLiters("5")
        liter = 2
        start = 0
      else if @digitalRead(sw_75L) is LOW
        setLiters("7.5")
        liter = 3
        start = 0
      else if @digitalRead(sw_10L) is LOW
        setLiters("10")
        liter = 4
        start = 0

  if liter > 0
    switch liter
      when 1 then setProgress(150000)
      when 2 then setProgress(300000)
      when 3 then setProgress(450000)
      when 4 then setProgress(600000)


  @digitalWrite(led_Koffie, LOW)
  @digitalWrite(led_Thee, LOW)
  @digitalWrite(led_WarmWater, LOW)
  @digitalWrite(led_Afwas, LOW)
  @digitalWrite(relais_lock, HIGH)

  lcddefaults()

eth_update = (must_delete) ->
  if must_delete
    request("#{tosend}/CoffeeCounter/remove.php?remove_id=#{secret}")
  else
    request "#{tosend}/CoffeeCounter/index.php?Quantity=#{liter}&Product=#{select}&Token=1234567890", (err, resp, body) ->
      secret = body if must_delete is false

createSelection = (led, type) ->
  @digitalWrite(led, HIGH)
  @digitalWrite(relais_lock, LOW)
  lcd.clear().setCursor(0, 0).print("/300  #{type}  /300").setCursor(0.1).print("Selecteer Liters")

setLiters = (amount) ->
  lcd.setCursor(0, 1).print(" #{amount} Liter ")

setProgress = (progress) ->
  @digitalWrite(relais_lock, HIGH)

  lcd.setCursor(0, 1).print("[              ]").setCursor(1, 1)
  for i in [1..15]
    if canmake is 0
      sleep(progress/14)
      lcd.print("/003")

  eth_update(false)

  secret = ""
  for i in [1..5]
    lcd.setCursor(0, 1).print("/003   Bereiding  /003")
    sleep(200)
    lcd.setCursor(0, 1).print("/003   Voltooid   /003")
    sleep(200)

bootloader = ->
  lcd.clear()
  lcd.setCursor(0, 0).print("    Illuzion    ")
  lcd.setCursor(0, 1).print("  Koffiezetter  ")
  sleep(1500)
  lcd.clear()
  lcd.setCursor(0, 0).print("    Made by :   ")
  lcd.setCursor(0, 1).print("   PiXeLBar  &  ")
  sleep(1000)
  lcd.setCursor(0, 1).print("    Bitlair     ")
  delay(1000)
  lcd.clear()
  lcd.setCursor(0, 0).print("  Please Enjoy  ")
  lcd.setCursor(0, 1).print("  Teh Coffeez!  ")
  sleep(800)
  lcd.clear()
  sleep(500)

lcddefaults = ->
  lcd.clear().setCursor(0, 0).print("/003   PiXeLBar   /003").setCursor(0, 1).print(" Maak een keuze ")

quote = ->
  number = Math.floor(Math.random() * 10)
  switch number
    when 0 then lcd.clear().setCursor(0, 0).print("Is het nog geen ").setCursor(0, 1).print(" tijd voor bier ")
    when 1 then lcd.clear().setCursor(0, 0).print("Lekker bakkie ? ").setCursor(0, 1).print("Of wil je thee ?")
    when 2 then lcd.clear().setCursor(0, 0).print(" Hiekie Faalt ! ").setCursor(0, 1).print(" FAAL FAAL FAAL ")
    when 3
      lcd.clear().setCursor(0, 0).print("Live nyan feed :").setCursor(0, 1).print(" NYAN NYAN NYAN ")
      sleep(400)
      lcd.setCursor(0, 1).print("N NYAN NYAN NYAN")
      sleep(400)
      lcd.setCursor(0, 1).print("AN NYAN NYAN NYA")
      sleep(400)
      lcd.setCursor(0, 1).print("YAN NYAN NYAN NY")
      sleep(400)
      lcd.setCursor(0, 1).print("NYAN NYAN NYAN N")
      sleep(400)
      lcd.setCursor(0, 1).print(" NYAN NYAN NYAN ")
    when 4 then lcd.clear().setCursor(0, 0).print("Als je dit leest").setCursor(0, 1).print(" Ik wil koffie! ")
    when 5 then lcd.clear().setCursor(0, 0).print(" Windows is kut ").setCursor(0, 1).print(" Ik wil LINUX!  ")
    when 6 then lcd.clear().setCursor(0, 0).print("Nu je hier toch ").setCursor(0, 1).print("bent,zet koffie!")
    when 7
      lcd.clear().setCursor(0, 0).print("   Voor stats : ").setCursor(0, 1).print("koffie.illuzion.")
      sleep(400)
      lcd.setCursor(0, 1).print("offie.illuzion.l")
      sleep(400)
      lcd.setCursor(0, 1).print("ffie.illuzion.la")
      sleep(400)
      lcd.setCursor(0, 1).print("fie.illuzion.lan")
    when 8 then lcd.clear().setCursor(0, 0).print(" Trolololololol ").setCursor(0, 1).print(" U iz Trolled!! ")
    when 9 then lcd.clear().setCursor(0, 0).print("Like this mod ? ").setCursor(0, 1).print("wiki.pixelbar.nl")

StopProduce = ->
  eth_update(true) if canmake is 0
  canmake = 1
  @digitalWrite(relais_lock, HIGH)
  lcd.clear().setCursor(0, 0).print(" What The FUCK! ").setCursor(0, 1).print("  Fatal FAAL!!  ")
  sleep(75000)
  lcd.clear().setCursor(0, 0).print("   Productie    ").setCursor(0, 1).print("  Geannuleerd   ")
  sleep(30000)
  lcddefaults()
