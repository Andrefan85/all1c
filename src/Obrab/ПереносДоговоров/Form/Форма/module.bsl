﻿
Процедура КнопкаВыполнитьНажатие(Кнопка)
	
	
	//СНАЧАЛА ОЧИСТИМ РЕГИСТРЫ
	//Запрос = Новый Запрос;
	//Запрос.Текст = 
	//	"ВЫБРАТЬ
	//	|	ДоговорыКонтрагентов.Ссылка КАК ДокументССылка,
	//	|	ДоговорыКонтрагентов.Наименование КАК Наименование
	//	|ИЗ
	//	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	//	|ГДЕ
	//	|	ДоговорыКонтрагентов.ДатаДоговора МЕЖДУ &ДатаНачала И &ДатаОкончания
	//	|	И НЕ ДоговорыКонтрагентов.ПометкаУдаления
	//	|
	//	|УПОРЯДОЧИТЬ ПО
	//	|	Наименование";
	//
	//Запрос.УстановитьПараметр("ДатаНачала", НачПериода);
	//Запрос.УстановитьПараметр("ДатаОкончания", КонПериода);
	//
	//РезультатЗапроса = Запрос.Выполнить();
	//
	//ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	//
	//Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
	//	РегистрОбъектыДО = РегистрыСведений.ОбъектыДокументооборота_РАВ.СоздатьНаборЗаписей();
	//	РегистрОбъектыДО.Отбор.Объект.Установить(ВыборкаДетальныеЗаписи.ДокументССылка);
	//	РегистрОбъектыДО.Записать(); 
	//	
	//	РегистрИнтегрированныеОбъекты = РегистрыСведений.ИнтегрированныеОбъекты.СоздатьНаборЗаписей();
	//	РегистрИнтегрированныеОбъекты.Отбор.Объект.Установить(ВыборкаДетальныеЗаписи.ДокументССылка);
	//	РегистрИнтегрированныеОбъекты.Записать();    		
	//КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДоговорыКонтрагентов.Ссылка КАК ДокументССылка,
		|	ЕСТЬNULL(ХранилищеДополнительнойИнформации.Ссылка, ЗНАЧЕНИЕ(Справочник.ХранилищеДополнительнойИнформации.ПустаяСсылка)) КАК ХранилищеДопИнформации,
		|	ХранилищеДополнительнойИнформации.Хранилище,
		|	ХранилищеДополнительнойИнформации.ИмяФайла
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ИнтегрированныеОбъекты КАК ИнтегрированныеОбъекты
		|		ПО ДоговорыКонтрагентов.Ссылка = ИнтегрированныеОбъекты.Объект
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ХранилищеДополнительнойИнформации КАК ХранилищеДополнительнойИнформации
		|		ПО (ХранилищеДополнительнойИнформации.Объект = ДоговорыКонтрагентов.Ссылка)
		|ГДЕ
		|	ДоговорыКонтрагентов.ДатаДоговора МЕЖДУ &ДатаНачала И &ДатаОкончания
		|	И НЕ ДоговорыКонтрагентов.ПометкаУдаления
		|	И ИнтегрированныеОбъекты.Объект ЕСТЬ NULL 
		|ИТОГИ
		|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ХранилищеДопИнформации)
		|ПО
		|	ДокументССылка";
	
	Запрос.УстановитьПараметр("ДатаНачала", НачПериода);
	Запрос.УстановитьПараметр("ДатаОкончания", КонПериода);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДокумент = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Прокси = ИнтеграцияС1СДокументооборотПовтИсп.ПолучитьПрокси();
	
	ИмяТипа = "DMInternalDocument";
	
	Индикатор = ПолучитьОбщуюФорму("ХодВыполненияОбработкиДанных");
	Индикатор.НаименованиеОбработкиДанных = "Перенос договоров";
	Индикатор.КомментарийОбработкиДанных = "Пожалуйста подождите...";
	Индикатор.Открыть();
	
	КолДокументов = ВыборкаДокумент.Количество();
	
	ИтВыборкаДокумент = 0;
	
	Пока ВыборкаДокумент.Следующий() Цикл
		
		ИтВыборкаДокумент = ИтВыборкаДокумент + 1;
		
		Индикатор.Значение = Окр(100*ИтВыборкаДокумент/КолДокументов,2);
		
		ВнешнийОбъект = ВыборкаДокумент.ДокументССылка;	
		Попытка
			ДокументXDTO = НовыйОбъектДокументооборотаПоОбъектуИС(Прокси, ВнешнийОбъект, ИмяТипа);  
		Исключение
			//Почему-то регистры заполняются при ошибке. 
			//Принудительно очистим
			РегистрОбъектыДО = РегистрыСведений.ОбъектыДокументооборота_РАВ.СоздатьНаборЗаписей();
			РегистрОбъектыДО.Отбор.Объект.Установить(ВнешнийОбъект);
			РегистрОбъектыДО.Записать(); 
			
			РегистрИнтегрированныеОбъекты = РегистрыСведений.ИнтегрированныеОбъекты.СоздатьНаборЗаписей();
			РегистрИнтегрированныеОбъекты.Отбор.Объект.Установить(ВнешнийОбъект);
			РегистрИнтегрированныеОбъекты.Записать(); 
			
			Продолжить;
		КонецПопытки;
		Если ПереноситьФайлыИзИС Тогда
			Сообщить(""+ВыборкаДокумент.ДокументССылка+" количество файлов "+ВыборкаДокумент.ХранилищеДопИнформации);
			ВыборкаДетали = ВыборкаДокумент.Выбрать();
			ПрикрепилиФайлы = Ложь;
			Пока ВыборкаДетали.Следующий() Цикл 				
				Если ВыборкаДетали.ХранилищеДопИнформации.Пустая() Тогда
					Продолжить;
				КонецЕсли; 			
				ДвоичныеДанные = ВыборкаДетали.Хранилище.Получить();
				Попытка
					ПолноеИмяФайла = СокрЛП(КаталогВременныхФайлов())+ВыборкаДетали.ИмяФайла;  				
					ДвоичныеДанные.Записать(ПолноеИмяФайла);   				
					Файл = Новый Файл(ПолноеИмяФайла); 				
					//Сообщить(ПолноеИмяФайла); 				
					ПрикрпепитьФайлКОбъектуДО(Прокси,ВнешнийОбъект,Файл,ДокументXDTO); 				
					УдалитьФайлы(ПолноеИмяФайла); 
				Исключение
					Сообщить("Не удалось выгрузить в каталог "+КаталогВременныхФайлов()+", объект "+СокрЛП(ВыборкаДетали.ДокументССылка)+", "+ВыборкаДетали.ИмяФайла);
				КонецПопытки; 				
				ПрикрепилиФайлы = Истина; 				
			КонецЦикла;  			
			Если ПрикрепилиФайлы Тогда 			
				РегистрОбъектыДО = РегистрыСведений.ОбъектыДокументооборота_РАВ.СоздатьНаборЗаписей();
				РегистрОбъектыДО.Отбор.Объект.Установить(ВнешнийОбъект);
				РегистрОбъектыДО.Прочитать();
				Для Каждого Запись Из РегистрОбъектыДО Цикл
					Запись.ЕстьФайлы = Истина;	
				КонецЦикла;     			
				РегистрОбъектыДО.Записать();   			
			КонецЕсли; 			
		КонецЕсли;
		
	КонецЦикла;
	
	Индикатор.Закрыть();
	
КонецПроцедуры

Процедура ВыбПериодНажатие(Элемент)
	НастройкаПериода = Новый НастройкаПериода;
	НастройкаПериода.РедактироватьКакИнтервал = Истина;
	НастройкаПериода.РедактироватьКакПериод = Истина;
	НастройкаПериода.ВариантНастройки = ВариантНастройкиПериода.Период;
	НастройкаПериода.УстановитьПериод(НачПериода, ?(КонПериода='0001-01-01', КонПериода, КонецДня(КонПериода)));
	Если НастройкаПериода.Редактировать() Тогда
		НачПериода = НастройкаПериода.ПолучитьДатуНачала();
		КонПериода = НастройкаПериода.ПолучитьДатуОкончания();
	КонецЕсли;
КонецПроцедуры

Процедура ПапкиДоговоровПапкаДокуменовНачалоВыбора(Элемент, СтандартнаяОбработка)
	
	СтруктураПапки = ВыбратьПапкуДоговоров(ЭтаФорма); 
	
	Если ТипЗнч(СтруктураПапки) = Тип("Структура") Тогда
		ТекСтрока = ЭлементыФормы.ПапкиДоговоров.ТекущиеДанные;
		ТекСтрока.ПапкаДокументов = СтруктураПапки.РеквизитПредставление;
		ТекСтрока.ИдПапки = СтруктураПапки.РеквизитID;  	
	КонецЕсли;
	
КонецПроцедуры

Процедура ИспользоватьСоответствиеПапокОрганизацииПриИзменении(Элемент)
	
	Если Элемент.Значение = Истина Тогда
		
		ПапкиДоговоров.Очистить();
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ДоговорыКонтрагентов.Организация
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|ГДЕ
		|	ДоговорыКонтрагентов.ДатаДоговора МЕЖДУ &ДатаНачала И &ДатаОкончания
		|	И НЕ ДоговорыКонтрагентов.ПометкаУдаления
		|
		|УПОРЯДОЧИТЬ ПО
		|	ДоговорыКонтрагентов.Организация.Наименование";
		
		Запрос.УстановитьПараметр("ДатаНачала", НачПериода);
		Запрос.УстановитьПараметр("ДатаОкончания", КонПериода);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();  		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл     
			Если НЕ ВыборкаДетальныеЗаписи.Организация.Пустая() Тогда
				НовСтр = ПапкиДоговоров.Добавить();
				НовСтр.Организация = ВыборкаДетальныеЗаписи.Организация;
			КонецЕсли;
		КонецЦикла;
		
	Иначе
		Если Вопрос("Табличная часть папок будет очищена. Продолжить?", РежимДиалогаВопрос.ДаНет) 
			= КодВозвратаДиалога.Да Тогда
			УстановитьВидимостьДоступность();
			ПапкиДоговоров.Очистить();
		КонецЕсли;
		
	КонецЕсли;
	
	ЭлементыФормы.ПапкиДоговоров.Видимость =  Элемент.Значение;   	
	
КонецПроцедуры


Процедура ПриОткрытии()
	
	УстановитьВидимостьДоступность();
	
	Если ТипЗнч(ВосстановитьЗначение("ВнешняяОбработка_ПереносДоговоров_ПапкиДоговоров")) = Тип("Массив") Тогда
		Массив = ВосстановитьЗначение("ВнешняяОбработка_ПереносДоговоров_ПапкиДоговоров");
		Если Массив.Количество() > 0 Тогда
			Для Ит = 0 По Массив.Количество()/3-1 Цикл
				НовСтр = ПапкиДоговоров.Добавить();
				НовСтр.Организация = Массив[0+Ит*3];
				НовСтр.ПапкаДокументов = Массив[1+Ит*3];
				НовСтр.ИдПапки = Массив[2+Ит*3];
			КонецЦикла;
			ЭлементыФормы.ИспользоватьСоответствиеПапокОрганизации.Значение = Истина;
			ЭлементыФормы.ПапкиДоговоров.Видимость = Истина;	
		КонецЕсли;
	КонецЕсли;
	
	НачПериода = ВосстановитьЗначение("ВнешняяОбработка_ПереносДоговоров_НачПериода");	
	КонПериода = ВосстановитьЗначение("ВнешняяОбработка_ПереносДоговоров_КонПериода");	
	
КонецПроцедуры

// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//
Процедура УстановитьВидимостьДоступность() 	
	
	ЭлементыФормы.ПапкиДоговоров.Видимость = ИспользоватьСоответствиеПапокОрганизации;	
	ЭлементыФормы.ПравилоЗаполнения.Видимость =  ИспользоватьОтдельноеПравило; 
	
КонецПроцедуры //УстановитьВидимостьДоступность

Процедура ИспользоватьОтдельноеПравилоПриИзменении(Элемент)
	
	ЭлементыФормы.ПравилоЗаполнения.Видимость =  Элемент.Значение; 
	
	Если Элемент.Значение = Ложь Тогда
		ПравилоЗаполнения = "";
	КонецЕсли; 	
	
КонецПроцедуры

Процедура ПриЗакрытии()
	Если ПапкиДоговоров.Количество() > 0 Тогда
		Массив = Новый Массив;
		Для Каждого Стр Из ПапкиДоговоров Цикл
			Массив.Добавить(Стр.Организация);
			Массив.Добавить(Стр.ПапкаДокументов);
			Массив.Добавить(Стр.ИдПапки);
		КонецЦикла;
	КонецЕсли;
	СохранитьЗначение("ВнешняяОбработка_ПереносДоговоров_ПапкиДоговоров", Массив);
	СохранитьЗначение("ВнешняяОбработка_ПереносДоговоров_НачПериода", НачПериода);
	СохранитьЗначение("ВнешняяОбработка_ПереносДоговоров_КонПериода", КонПериода);
КонецПроцедуры



