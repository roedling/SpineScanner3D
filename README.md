# SpineScanner3D                                    ![Homescreen1Klein](https://user-images.githubusercontent.com/50517024/112753432-ee149900-8fd7-11eb-9b8c-7e4a81cc0b87.jpg)

**Die Entwicklung dieser App fand im Rahmen meiner Bachelorarbeit statt.**

In dieser Bachelorarbeit geht es um die Implementierung einer Gesundheitsapp für das iPhone 12 Pro. 
Dabei wird der eingebaute 3D Sensor des Handys verwendet, um den Rücken eines Patienten zu scannen. 
Durch die folgende Darstellung eines 3D-Modells und Rückgabe einiger wichtiger Parameter können so 
Diagnosen von Fehlstellungen der Wirbelsäule gestellt, sowie diese kontrolliert werde.

This bachelor-thesis is about the implementation of a health app for the iPhone 12 Pro. 
The built-in 3D sensor of the phone is used to scan a patient's back. 
By displaying a 3D model and returning some important parameters, diagnoses of misalignments 
of the spine can be made and checked.

## Idee 
Die Idee der App war eine vereinfachte Version von formetric 3D, einem bereits bestehenden Produkt der Firma Diers,
zu entwickeln, welche durch ihre Mobilität jederzeit und an jedem Ort verwendet werden kann. 
Dabei soll, aufgrund des eingebauten LiDAR-Sensors, das iPhone 12 Pro zum Einsatz kommen. 
Die Anwendung soll durch eine kurze Aufnahme des Rückens des Patienten die wichtigsten Parameter 
ausgeben, um so eine gute Kontrolle von einer Fehlstellung zu erhalten. 
Dabei ist neben der Parameterausgabe auch die Darstellung des 3D Models mit verschiedenen Shadern wichtig. 
Um die Aufnahmen eines Patienten auf lange Sicht vergleichen zu können, müssen die gewonnenen Daten 
gespeichert und auch wieder geladen werden können. Die Anwendung soll möglichst einfach gehalten sein, 
um die bereits existierenden Produkte von Diers nicht abzulösen.
Die Anwendung richtet sich in erster Linie an Ärzte, die beispielsweise nicht genug Platz in ihrer Praxis 
haben, um ein formetric einzusetzen oder eine Möglichkeit suchen ihren Patienten unkompliziert 
und kurz scannen zu können. Außerdem an Physiothera-peuten, die damit die Fortschritte des Patienten 
dokumentieren und an den zuständigen Arzt weiterleiten können.

## Ergebnis 
#### LoginViewController

![LoginKlein](https://user-images.githubusercontent.com/50517024/112753003-261adc80-8fd6-11eb-9ce2-bbef2a6fd67c.png)

#### CameraViewController

![lidar ansichtKlein](https://user-images.githubusercontent.com/50517024/112753313-67f85280-8fd7-11eb-929d-a7335e221a31.png)
![kamera ansichtKlein](https://user-images.githubusercontent.com/50517024/112753320-6cbd0680-8fd7-11eb-9bbc-79f484e65e82.png)

#### ModelViewController

![IMG_0063Klein](https://user-images.githubusercontent.com/50517024/112752981-084d7780-8fd6-11eb-9451-76b570319eaa.png)
![IMG_0061Klein](https://user-images.githubusercontent.com/50517024/112752965-ebb13f80-8fd5-11eb-99cc-efe8b11459f9.png)
![IMG_0062Klein](https://user-images.githubusercontent.com/50517024/112753022-4054ba80-8fd6-11eb-8d49-001d43f8627a.png)

![IMG_0064Klein](https://user-images.githubusercontent.com/50517024/112753210-f28c8200-8fd6-11eb-910b-cc49eedfaa81.png)
![kariertKlein](https://user-images.githubusercontent.com/50517024/112753214-f91af980-8fd6-11eb-903a-3debac1f86bf.png)
![IMG_0066Klein](https://user-images.githubusercontent.com/50517024/112753220-fddfad80-8fd6-11eb-8f52-035d0c685653.png)

#### ParameterViewController

![parameter screenKlein](https://user-images.githubusercontent.com/50517024/112753257-249de400-8fd7-11eb-98ab-ac6d40e3a9d5.png)
