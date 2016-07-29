﻿Перем СохраненнаяНастройка Экспорт;        // Текущий вариант отчета

Перем ТаблицаВариантовОтчета Экспорт;      // Таблица вариантов доступных текущему пользователю

#Если Клиент ИЛИ ВнешнееСоединение Тогда
	
// Функция формирует отчет
//
Функция СформироватьОтчет(Результат = Неопределено, ДанныеРасшифровки = Неопределено, ВыводВФормуОтчета = Истина, СтруктураНастроекСМТ = Неопределено) Экспорт
	
	//НастрокаПоУмолчанию        = КомпоновщикНастроек.ПолучитьНастройки();
	//ТиповыеОтчеты.ПолучитьПримененуюНастройку(ЭтотОбъект);
	//ТиповыеОтчеты.СформироватьТиповойОтчет(ЭтотОбъект, Результат, ДанныеРасшифровки, ВыводВФормуОтчета);
	//КомпоновщикНастроек.ЗагрузитьНастройки(НастрокаПоУмолчанию);
	
	НастройкаСКД        = КомпоновщикНастроек.ПолучитьНастройки();
	ТиповыеОтчеты.ПолучитьПримененуюНастройку(ЭтотОбъект);
	
	ПараметрДатаНачала = НачалоНедели(ТекущаяДата())-60*60*24*7;
	ПараметрДатаОкончания = КонецДня(ТекущаяДата());
	
	ПараметрОрганизация = ОпределитьСамуюЧастоИспользуемуюОрганизацию();
	
	ПараметрНачалоПериода = КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("НачалоПериода1"));
	ПараметрКонецПериода = КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("КонецПериода1"));
	ПараметрОрганизация = КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("Организация"));
	
	
	
	ТЗДанныхПУЛ = ПолучитьТаблицуДанных(ПараметрНачалоПериода.Значение, ПараметрКонецПериода.Значение, ПараметрОрганизация.Значение, СтруктураНастроекСМТ);
	
	ТЗЗаправки = ПолучитьЗаправкиСМТ(ПараметрНачалоПериода.Значение, ПараметрКонецПериода.Значение, ПараметрОрганизация.Значение, СтруктураНастроекСМТ);

	ВнешниеНаборыДанных = Новый Структура;
	ВнешниеНаборыДанных.Вставить("ТЗДанныеПутевыелисты",ТЗДанныхПУЛ);
	ВнешниеНаборыДанных.Вставить("ТЗЗаправки",ТЗЗаправки);
	
	ТиповыеОтчеты.СформироватьТиповойОтчет(ЭтотОбъект, Результат, ДанныеРасшифровки, ВыводВФормуОтчета, ВнешниеНаборыДанных);
	КомпоновщикНастроек.ЗагрузитьНастройки(НастройкаСКД);
		
КонецФункции

Функция ОпределитьСамуюЧастоИспользуемуюОрганизацию()
	
		//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ИнтекоУчетЗаправок.Регистратор.Организация КАК РегистраторОрганизация,
		|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ИнтекоУчетЗаправок.Регистратор) КАК КолвоДокументов
		|ПОМЕСТИТЬ ВТ
		|ИЗ
		|	РегистрНакопления.ИнтекоУчетЗаправок КАК ИнтекоУчетЗаправок
		|ГДЕ
		|	ИнтекоУчетЗаправок.Период МЕЖДУ &НачалоПериода И &КонецПериода
		|
		|СГРУППИРОВАТЬ ПО
		|	ИнтекоУчетЗаправок.Регистратор.Организация
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ ПЕРВЫЕ 1
		|	ВТ.РегистраторОрганизация КАК РегистраторОрганизация,
		|	ВТ.КолвоДокументов КАК КолвоДокументов
		|ИЗ
		|	ВТ КАК ВТ
		|
		|УПОРЯДОЧИТЬ ПО
		|	КолвоДокументов УБЫВ";
	
	Запрос.УстановитьПараметр("КонецПериода", КонецГода(ТекущаяДата()));
	Запрос.УстановитьПараметр("НачалоПериода", НачалоГода(ТекущаяДата()));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	ПарОрганизация = Справочники.Организации.ПустаяСсылка();
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		ПарОрганизация = ВыборкаДетальныеЗаписи.РегистраторОрганизация;
	КонецЕсли;
	
	Возврат ПарОрганизация;
	
КонецФункции

Функция ПолучитьЗаправкиСМТ(ДатаНачала, ДатаОкончания, Организация, СтруктураНастроекСМТ)
	
	Если СтруктураНастроекСМТ = Неопределено Тогда
		Предупреждение("Не удалось определить настройки системы мониторинга!");
		Возврат Новый ТаблицаЗначений;
	Иначе		
		//АдресТелематическогоСервера = СтруктураНастроекСМТ.АдресТелематическогоСервера;
		//ИдОтчетаДляПолученияДанных  = СтруктураНастроекСМТ.ИдОтчетаДляПолученияДанных;
		//ИдШаблонаДляПолученияДанных = СтруктураНастроекСМТ.ИдШаблонаДляПолученияДанных;
		//ИмяОтчетаДляПолученияДанных = СтруктураНастроекСМТ.ИмяОтчетаДляПолученияДанных;
		//Логин 						= СтруктураНастроекСМТ.Логин;
		//Пароль 						= СтруктураНастроекСМТ.Пароль;
		//ПортТелематическогоСервера  = СтруктураНастроекСМТ.ПортТелематическогоСервера;
		//ЧасовойПояс 				= СтруктураНастроекСМТ.ЧасовойПояс;
		ХранениеИдТехники           = СтруктураНастроекСМТ.ХранениеИдТехники;
		СвойствоАЗС		            = СтруктураНастроекСМТ.СвойствоАЗС;
		СвойствоАЗК		            = СтруктураНастроекСМТ.СвойствоАЗК;
		//Токен          				= СтруктураНастроекСМТ.Токен; 
	КонецЕсли;     	
	
	//Определим основные средства и id техники АЗС и АЗК
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СвойствоАЗС.Объект КАК Техника,
		|	ЕСТЬNULL(СвойствоИд.Значение, 0) КАК IDТехники,
		|	""АЗС"" КАК ПризнакЗаправщика
		|ИЗ
		|	РегистрСведений.ЗначенияСвойствОбъектов КАК СвойствоАЗС
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияСвойствОбъектов КАК СвойствоИд
		|		ПО СвойствоАЗС.Объект = СвойствоИд.Объект
		|ГДЕ
		|	СвойствоАЗС.Свойство = &СвойствоАЗС
		|	И СвойствоАЗС.Значение = ИСТИНА
		|	И СвойствоИд.Свойство = &ХранениеИдТехники
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	СвойствоАЗК.Объект,
		|	ЕСТЬNULL(СвойствоИд.Значение, 0),
		|	""АЗК""
		|ИЗ
		|	РегистрСведений.ЗначенияСвойствОбъектов КАК СвойствоАЗК
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияСвойствОбъектов КАК СвойствоИд
		|		ПО СвойствоАЗК.Объект = СвойствоИд.Объект
		|ГДЕ
		|	СвойствоАЗК.Свойство = &СвойствоАЗК
		|	И СвойствоАЗК.Значение = ИСТИНА
		|	И СвойствоИд.Свойство = &ХранениеИдТехники";
	
	Запрос.УстановитьПараметр("СвойствоАЗК", СвойствоАЗК);
	Запрос.УстановитьПараметр("СвойствоАЗС", СвойствоАЗС);
	Запрос.УстановитьПараметр("ХранениеИдТехники", ХранениеИдТехники);
	
	ТЗЗаправщиков = Запрос.Выполнить().Выгрузить();
	
	ОписаниеТиповЧисло = Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(10,2));
	ОписаниеТиповСтрока = Новый ОписаниеТипов("Строка", Новый КвалификаторыСтроки(100));	
		
	ТЗЗаправок = Новый ТаблицаЗначений;
	ТЗЗаправок.Колонки.Добавить("Заправщик",ОписаниеТиповСтрока);
	ТЗЗаправок.Колонки.Добавить("ТипЗаправщика",ОписаниеТиповСтрока);
	ТЗЗаправок.Колонки.Добавить("НомерЗаправки",ОписаниеТиповСтрока);
	ТЗЗаправок.Колонки.Добавить("ЗаправленоАЗК",ОписаниеТиповЧисло);
	ТЗЗаправок.Колонки.Добавить("ЗаправленоАЗС",ОписаниеТиповЧисло);
	ТЗЗаправок.Колонки.Добавить("ИмяКлюча",ОписаниеТиповСтрока);
	
	//Получим данные по заправкам АЗС
	ОтборАЗС = Новый Структура("ПризнакЗаправщика","АЗС");
	МассивАЗС =  ТЗЗаправщиков.НайтиСтроки(ОтборАЗС);
	ЗаправкиАЗС = ПолучитьЗаправки(МассивАЗС,ДатаНачала, ДатаОкончания, Организация, СтруктураНастроекСМТ,ТЗЗаправок);  //возвращается ТЗ
	
	ОтборАЗК = Новый Структура("ПризнакЗаправщика","АЗК");
	МассивАЗК =  ТЗЗаправщиков.НайтиСтроки(ОтборАЗК);
	ЗаправкиАЗК = ПолучитьЗаправки(МассивАЗК,ДатаНачала, ДатаОкончания, Организация, СтруктураНастроекСМТ,ТЗЗаправок);  //возвращается ТЗ  	
	
	Возврат ТЗЗаправок;
	
КонецФункции

Функция ПолучитьЗаправки(МассивТехники,ДатаНачала, ДатаОкончания, Организация, СтруктураНастроекСМТ,ТЗЗаправок)
	
	АдресТелематическогоСервера = СтруктураНастроекСМТ.АдресТелематическогоСервера;
	ИдОтчетаДляПолученияДанных  = СтруктураНастроекСМТ.ИдОтчетаДляПолученияДанных;
	ИдШаблонаДляПолученияДанных = СтруктураНастроекСМТ.ИдШаблонаДляПолученияДанных;
	ИдШаблонаДляЗаправок		= СтруктураНастроекСМТ.ИдШаблонаДляЗаправок;  		
	ИмяОтчетаДляПолученияДанных = СтруктураНастроекСМТ.ИмяОтчетаДляПолученияДанных;
	Логин 						= СтруктураНастроекСМТ.Логин;
	Пароль 						= СтруктураНастроекСМТ.Пароль;
	ПортТелематическогоСервера  = СтруктураНастроекСМТ.ПортТелематическогоСервера;
	ЧасовойПояс 				= СтруктураНастроекСМТ.ЧасовойПояс;
	ХранениеИдТехники           = СтруктураНастроекСМТ.ХранениеИдТехники;
	СвойствоАЗС		            = СтруктураНастроекСМТ.СвойствоАЗС;
	СвойствоАЗК		            = СтруктураНастроекСМТ.СвойствоАЗК;
	Токен          				= СтруктураНастроекСМТ.Токен;
	
	СмещениеВремени = ЧасовойПояс*60*60;
	СмещениеВремениСтрокой = СтрЗаменить(СокрЛП(ЧасовойПояс*60*60),Символы.НПП,"");
		
	
	Сервер = АдресТелематическогоСервера;	
	Сервер = СтрЗаменить(Сервер,"http://","");	
	Сервер = СтрЗаменить(Сервер,"https://","");	
	HTTP =  Новый HTTPСоединение(Сервер,ПортТелематическогоСервера);
	
	//Токен = "f6d3b150f3a27f440a91eb22c574343cC523D64898F815969C43E026A5416A761C882B59";
	//f6d3b150f3a27f440a91eb22c574343c36A74771B24C3E78C2953D6FDE5E861237E3D564
	//f6d3b150f3a27f440a91eb22c574343cC523D64898F815969C43E026A5416A761C882B59
	//Токен = "f6d3b150f3a27f440a91eb22c574343cD22B18F7157BCE4094D0F48AA580DD8A87068958";
	
	//получим sid	
	иТекстЗапроса = "/wialon/ajax.html?svc=token/login&params={token:""" + Токен + """}";
	ЗапросКСерверу = Новый HTTPЗапрос(иТекстЗапроса);
	Ответ = HTTP.Получить(ЗапросКСерверу);
	Если Ответ.КодСостояния = 200 Тогда
		ОтветСтрока = Ответ.ПолучитьТелоКакСтроку();
	КонецЕсли;
	
	ПроверитьВозвратСМТ(ОтветСтрока,"Не прошла проверка токена!"); 	
	
	СтрокаEid = Найти(ОтветСтрока,"""eid"":""");
	
	Если СтрокаEid > 0 Тогда
		SessionID = Сред(ОтветСтрока,СтрокаEid+7,32);
	КонецЕсли;
	
	//Установим часовой пояс, смещение времени и язык отчета
	
	часпоясТекстЗапроса = "/wialon/ajax.html?sid=" + SessionID + 
	"&svc=render/set_locale&params={""tzOffset"":" + СмещениеВремениСтрокой + ",""language"":""ru"",""flags"":""""}";
	
	//часпоясТекстЗапроса = "/wialon/ajax.html?sid=" + SessionID + 
	//		"&svc=render/set_locale&params={""tzOffset"":0,""language"":""ru"",""flags"":""""}";
	
	ЗапросКСерверу = Новый HTTPЗапрос(часпоясТекстЗапроса);
	Ответ = HTTP.Получить(ЗапросКСерверу);
	Если Ответ.КодСостояния = 200 Тогда
		ОтветСтрока = Ответ.ПолучитьТелоКакСтроку();
		Если СокрЛП(ОтветСтрока) = "{}" Тогда
			//Сообщить("Смещение времени установлено");
		Иначе
			Сообщить("Ошибка при установке смещении времени");
		КонецЕсли;
	Иначе
		Сообщить("Ошибка при установке смещении времени");   		
	КонецЕсли;
	
	Ит = 0;
	
	Для каждого ЭлМассива Из МассивТехники Цикл 
		
		ИдТехники = ЭлМассива["IDТехники"];
		
		Если ИдТехники = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		Ит = Ит + 1;
		
		//получим даныне по какой-то технике  (текущая дата)  	
		техТекстЗапроса1 = "/wialon/ajax.html?sid=" + SessionID + 
		"&svc=report/exec_report&params={""reportResourceId"":13856467,""reportTemplateId"":4,""reportObjectId"":" + 
		СокрЛП(ИдТехники) + ",""reportObjectSecId"":0,""interval"":{""from"":0,""to"":1,""flags"":0x02}} """;
		//
		//за указанное время 
		ДатаНачалаСМТ = СокрЛП(СтрЗаменить(ДатаНачала + СмещениеВремени - Дата(1970,1,1,0,0,0),Символы.НПП,""));
		ДатаОкончанияСМТ = СокрЛП(СтрЗаменить(ДатаОкончания + СмещениеВремени - Дата(1970,1,1,0,0,0),Символы.НПП,""));
		техТекстЗапроса = "/wialon/ajax.html?sid=" + SessionID + 
		"&svc=report/exec_report&params={""reportResourceId"":"+ИдОтчетаДляПолученияДанных+",""reportTemplateId"":" + ИдШаблонаДляЗаправок + ",""reportObjectId"":" + 
		СокрЛП(ИдТехники) + ",""reportObjectSecId"":0,""interval"":{""from"":" + ДатаНачалаСМТ + 
		",""to"":" + ДатаОкончанияСМТ + ",""flags"":0x00}} """;
		
		ЗапросКСерверу = Новый HTTPЗапрос(техТекстЗапроса);
		Ответ = HTTP.Получить(ЗапросКСерверу);
		Если Ответ.КодСостояния = 200 Тогда
			ОтветСтрока = Ответ.ПолучитьТелоКакСтроку();
		КонецЕсли;
		
		Если Найти(ОтветСтрока,"{""error"":7}") > 0 Тогда
			//Ошибка доступа, скорее всего id с другой СМТ
			Продолжить;
		КонецЕсли;
		
		ПроверитьВозвратСМТ(ОтветСтрока,"Ошибка при получении данных по технике "+СокрЛП(ЭлМассива["Техника"]));
		
		техРезультат = ОтветСтрока; 
		
		//Определим возвращенное количество строк чтобы передать в параметр вложенного запроса
		ПараметрПо = "999";//поставим побольше по умолчанию
		ПозСтрок = Найти(техРезультат,"""rows"":");
		Если ПозСтрок > 0 Тогда
			СтрокаДляРазбора = Сред(техРезультат,ПозСтрок+7,10);
			ПозЗапятой = Найти(СтрокаДляРазбора,",");
			Если ПозЗапятой > 0 Тогда
				ПараметрПо = Лев(СтрокаДляРазбора,ПозЗапятой-1);
			КонецЕсли;
		КонецЕсли;
		
		// Получим развернутые данные по технике из вложенной таблицы
		вложТекстЗапроса = "/wialon/ajax.html?sid=" + SessionID + 
		"&svc=report/select_result_rows&params={""tableIndex"":0,""config"":{""type"":""range"",""data"":{""from"":0,""to"":"+ПараметрПо+",""level"":1}}}";

		ЗапросКСерверу = Новый HTTPЗапрос(вложТекстЗапроса);
		Ответ = HTTP.Получить(ЗапросКСерверу);
		Если Ответ.КодСостояния = 200 Тогда
			ОтветСтрока = Ответ.ПолучитьТелоКакСтроку();
		КонецЕсли;
		
		Если Найти(ОтветСтрока,"{""error"":7}") > 0 Тогда
			//Ошибка доступа, скорее всего id с другой СМТ
			Продолжить;
		КонецЕсли;
		
		Если Найти(ОтветСтрока,"{""error"":5}") > 0 Тогда
			//Не удалось сформировать отчет. Скорее всего, нет данных за выбранный период
			Сообщить("Нет данных по завправке по технике " + СокрЛП(ЭлМассива["Техника"]) + " за выбранный период");
			Продолжить;
		КонецЕсли;
		
		ПроверитьВозвратСМТ(ОтветСтрока,"Ошибка при получении данных по технике "+СокрЛП(ЭлМассива["Техника"]));
		
		вложРезультат = ОтветСтрока;
		
		
	//	"https: //hst-api.wialon.com/wialon/ajax.html?svc=report/select_result_rows&params={""tableIndex"":0,""config"":{""type"":""range"",""data"":{""from"":0,""to"":100,""level"":1}}}&sid=0156035d0cdf4cb8ad845e0c90068021"
		
		
		//находим статистику и обрезаем ненужные данные 
		
		//ТЗЗаправок.Очистить();
		
		ПозицияНачалоЗаправки = Найти(вложРезультат,"""c"":["); 
		ПозицияКонецЗаправки = Найти(вложРезультат,"]},");
		Пока ПозицияНачалоЗаправки > 0 И ПозицияКонецЗаправки > 0 Цикл
			СтрокаСтатистикаЗаправки = Сред(вложРезультат,ПозицияНачалоЗаправки+5,ПозицияКонецЗаправки - ПозицияНачалоЗаправки - 5);
			ДобавитьСтрокуВТЗ(СтрокаСтатистикаЗаправки,ТЗЗаправок,ЭлМассива);
			вложРезультат = Прав(вложРезультат,СтрДлина(вложРезультат)- ПозицияКонецЗаправки); 
			ПозицияНачалоЗаправки = Найти(вложРезультат,"""c"":["); 
			ПозицияКонецЗаправки = Найти(вложРезультат,"]},"); 			
		КонецЦикла; 	
		
		////1. Ищем поле "Нач. уровень" (12 символов)
		//Стр.ОстатокНаНачалоСМТ = ПолучитьЗначениеИзСтатистики(СтрокаСтатистика,"Нач. уровень",12);
		//
		////2. Ищем поле "Всего заправлено" (16 символов)
		//Стр.ЗаправакаПоПоказаниямСМТ = ПолучитьЗначениеИзСтатистики(СтрокаСтатистика,"Всего заправлено",16);
		//
		////3. Ищем поле "Потрачено по ДУТ"  (16 символов)
		//Стр.РасходГСМПоПоказателямСМТ = ПолучитьЗначениеИзСтатистики(СтрокаСтатистика,"Потрачено по ДУТ",16);
		//
		////4. Ищем поле "Конеч. уровень" (14 символов) 
		//Стр.ОстатокНаКонецСМТ = ПолучитьЗначениеИзСтатистики(СтрокаСтатистика,"Конеч. уровень",14);
		//
		////5. Ищем поле "Всего топлива слито"  (19 символов)
		//Стр.СливТопливаПоСМТ = ПолучитьЗначениеИзСтатистики(СтрокаСтатистика,"Всего топлива слито",19); 		
		
	КонецЦикла;
	
	Возврат ТЗЗаправок;
		
КонецФункции

Процедура ДобавитьСтрокуВТЗ(СтрокаJSON,ТЗ,ЭлМассива)
	
	НовСтр = ТЗ.Добавить();
	//номер заправки
	ПозЗапятой = Найти(СтрокаJSON,""",""");
	СтрокаНомерЗаправки = СтрЗаменить(Лев(СтрокаJSON,ПозЗапятой),"""","");
	НовСтр.НомерЗаправки = СтрокаНомерЗаправки;
	
	//заправлено
	ПризнакЗаправщика = ЭлМассива["ПризнакЗаправщика"];
	СтрокаJSON = Прав(СтрокаJSON,СтрДлина(СтрокаJSON)-ПозЗапятой-2);
	ПозЗапятой = Найти(СтрокаJSON,""",""");
	СтрокаЗаправлено = СтрЗаменить(Лев(СтрокаJSON,ПозЗапятой),"""","");
	
	МаскаЧисел = "0123456789.,";
	ЗначениеЧисло = "";
	Для Ит = 1 По СтрДлина(СтрокаЗаправлено) Цикл
		Если Найти(МаскаЧисел,Сред(СтрокаЗаправлено,Ит,1)) > 0 Тогда
			ЗначениеЧисло = ЗначениеЧисло + Сред(СтрокаЗаправлено,Ит,1);
		КонецЕсли;
	КонецЦикла;
	НовСтр["Заправлено"+ПризнакЗаправщика] = Число(ЗначениеЧисло); 	
	
	//имя ключа заправки
	СтрокаJSON = Прав(СтрокаJSON,СтрДлина(СтрокаJSON)-ПозЗапятой-2);
	СтрокаИмяКлюча = Лев(СтрокаJSON,СтрДлина(СтрокаJSON)-1);
	НовСтр.ИмяКлюча = СтрокаИмяКлюча;
	
	НовСтр.Заправщик = ЭлМассива["Техника"];
	НовСтр.Типзаправщика = ЭлМассива["ПризнакЗаправщика"];
	
		
КонецПроцедуры



Функция ПолучитьТаблицуДанных(ДатаНачала, ДатаОкончания, Организация, СтруктураНастроекСМТ)
	
	Если СтруктураНастроекСМТ = Неопределено Тогда
		Предупреждение("Не удалось определить настройки системы мониторинга!");
		Возврат Новый ТаблицаЗначений;
	Иначе		
		АдресТелематическогоСервера = СтруктураНастроекСМТ.АдресТелематическогоСервера;
		ИдОтчетаДляПолученияДанных  = СтруктураНастроекСМТ.ИдОтчетаДляПолученияДанных;
		ИдШаблонаДляПолученияДанных = СтруктураНастроекСМТ.ИдШаблонаДляПолученияДанных;
		ИмяОтчетаДляПолученияДанных = СтруктураНастроекСМТ.ИмяОтчетаДляПолученияДанных;
		Логин 						= СтруктураНастроекСМТ.Логин;
		Пароль 						= СтруктураНастроекСМТ.Пароль;
		ПортТелематическогоСервера  = СтруктураНастроекСМТ.ПортТелематическогоСервера;
		ЧасовойПояс 				= СтруктураНастроекСМТ.ЧасовойПояс;
		ХранениеИдТехники           = СтруктураНастроекСМТ.ХранениеИдТехники;
		Токен          				= СтруктураНастроекСМТ.Токен;
	КонецЕсли;
	
	СмещениеВремени = ЧасовойПояс*60*60;
	СмещениеВремениСтрокой = СтрЗаменить(СокрЛП(ЧасовойПояс*60*60),Символы.НПП,"");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	ИнтекоУчетГСМ.Техника,
		|	ВЫБОР
		|		КОГДА ИнтекоУчетГСМ.Регистратор ССЫЛКА Документ.ИнтекоПутевойЛистТракториста
		|			ТОГДА ИнтекоУчетГСМ.Регистратор.Сотрудник
		|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.СотрудникиОрганизаций.ПустаяСсылка)
		|	КОНЕЦ КАК ТрактористВодитель,
		|	СУММА(ЕСТЬNULL(НормаГСМИзПУЛ.РасходНорма, 0)) КАК РасходГСМПоНорме1С,
		|	СУММА(ИнтекоУчетГСМ.Количество) КАК РасходГСМПоФакту1С
		|ПОМЕСТИТЬ РасходГСМТракторы
		|ИЗ
		|	РегистрНакопления.ИнтекоУчетГСМ КАК ИнтекоУчетГСМ
		|		ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|			СУММА(ИнтекоПутевойЛистТрактористаГСМ.РасходНорма) КАК РасходНорма,
		|			ИнтекоПутевойЛистТрактористаГСМ.Ссылка.Ссылка КАК ПутевойЛистТрактора
		|		ИЗ
		|			Документ.ИнтекоПутевойЛистТракториста.ГСМ КАК ИнтекоПутевойЛистТрактористаГСМ
		|		ГДЕ
		|			ИнтекоПутевойЛистТрактористаГСМ.Ссылка.Дата МЕЖДУ &НачалоПериода И &КонецПериода
		|			И ИнтекоПутевойЛистТрактористаГСМ.Ссылка.Проведен = ИСТИНА
		|			И ИнтекоПутевойЛистТрактористаГСМ.Ссылка.Организация = &Организация
		|		
		|		СГРУППИРОВАТЬ ПО
		|			ИнтекоПутевойЛистТрактористаГСМ.Ссылка.Ссылка) КАК НормаГСМИзПУЛ
		|		ПО ИнтекоУчетГСМ.Регистратор = НормаГСМИзПУЛ.ПутевойЛистТрактора
		|ГДЕ
		|	ИнтекоУчетГСМ.ВидДвижения = ЗНАЧЕНИЕ(ВидДвиженияНакопления.Расход)
		|	И ИнтекоУчетГСМ.Период МЕЖДУ &НачалоПериода И &КонецПериода
		|	И ИнтекоУчетГСМ.Регистратор.Организация = &Организация
		|	И ИнтекоУчетГСМ.Регистратор.Дата МЕЖДУ &НачалоПериода И &КонецПериода
		|
		|СГРУППИРОВАТЬ ПО
		|	ИнтекоУчетГСМ.Техника,
		|	ВЫБОР
		|		КОГДА ИнтекоУчетГСМ.Регистратор ССЫЛКА Документ.ИнтекоПутевойЛистТракториста
		|			ТОГДА ИнтекоУчетГСМ.Регистратор.Сотрудник
		|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.СотрудникиОрганизаций.ПустаяСсылка)
		|	КОНЕЦ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	ИнтекоИспользованиеГСМ.Техника,
		|	СУММА(ИнтекоИспользованиеГСМ.Количество) КАК РасходГСМПоФакту1С,
		|	ВЫБОР
		|		КОГДА ИнтекоИспользованиеГСМ.Регистратор ССЫЛКА Документ.ИнтекоПутевойЛистАвтотранспорта
		|			ТОГДА ИнтекоИспользованиеГСМ.Регистратор.Водитель
		|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.СотрудникиОрганизаций.ПустаяСсылка)
		|	КОНЕЦ КАК ТрактористВодитель,
		|	СУММА(ЕСТЬNULL(НормаГСМИзПУЛ.РасходНорма, 0)) КАК РасходГСМПоНорме1С
		|ПОМЕСТИТЬ РасходГСМАвтомобили
		|ИЗ
		|	РегистрНакопления.ИнтекоИспользованиеГСМ КАК ИнтекоИспользованиеГСМ
		|		ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|			ИнтекоПутевойЛистАвтотранспортаТЧРаботаТехники.Ссылка.Ссылка КАК ПутевойЛистАвтомобиля,
		|			СУММА(ИнтекоПутевойЛистАвтотранспортаТЧРаботаТехники.НормативРасходТоплива) КАК РасходНорма
		|		ИЗ
		|			Документ.ИнтекоПутевойЛистАвтотранспорта.ТЧРаботаТехники КАК ИнтекоПутевойЛистАвтотранспортаТЧРаботаТехники
		|		ГДЕ
		|			ИнтекоПутевойЛистАвтотранспортаТЧРаботаТехники.Ссылка.Дата МЕЖДУ &НачалоПериода И &КонецПериода
		|			И ИнтекоПутевойЛистАвтотранспортаТЧРаботаТехники.Ссылка.Проведен = ИСТИНА
		|			И ИнтекоПутевойЛистАвтотранспортаТЧРаботаТехники.Ссылка.Организация = &Организация
		|		
		|		СГРУППИРОВАТЬ ПО
		|			ИнтекоПутевойЛистАвтотранспортаТЧРаботаТехники.Ссылка.Ссылка) КАК НормаГСМИзПУЛ
		|		ПО ИнтекоИспользованиеГСМ.Регистратор = НормаГСМИзПУЛ.ПутевойЛистАвтомобиля
		|ГДЕ
		|	ИнтекоИспользованиеГСМ.ВидДвижения = ЗНАЧЕНИЕ(ВидДвиженияНакопления.Расход)
		|	И ИнтекоИспользованиеГСМ.Период МЕЖДУ &НачалоПериода И &КонецПериода
		|	И ИнтекоИспользованиеГСМ.Регистратор.Организация = &Организация
		|
		|СГРУППИРОВАТЬ ПО
		|	ИнтекоИспользованиеГСМ.Техника,
		|	ВЫБОР
		|		КОГДА ИнтекоИспользованиеГСМ.Регистратор ССЫЛКА Документ.ИнтекоПутевойЛистАвтотранспорта
		|			ТОГДА ИнтекоИспользованиеГСМ.Регистратор.Водитель
		|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.СотрудникиОрганизаций.ПустаяСсылка)
		|	КОНЕЦ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	ИнтекоУчетЗаправок.Техника,
		|	ИнтекоУчетЗаправок.Сотрудник,
		|	СУММА(ИнтекоУчетЗаправок.Количество) КАК Количество
		|ПОМЕСТИТЬ Заправки
		|ИЗ
		|	РегистрНакопления.ИнтекоУчетЗаправок КАК ИнтекоУчетЗаправок
		|ГДЕ
		|	ИнтекоУчетЗаправок.Период МЕЖДУ &НачалоПериода И &КонецПериода
		|	И ИнтекоУчетЗаправок.Регистратор.Организация = &Организация
		|
		|СГРУППИРОВАТЬ ПО
		|	ИнтекоУчетЗаправок.Техника,
		|	ИнтекоУчетЗаправок.Сотрудник
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	РасходГСМТракторы.Техника,
		|	РасходГСМТракторы.ТрактористВодитель,
		|	РасходГСМТракторы.РасходГСМПоНорме1С КАК РасходГСМПоНорме1С,
		|	ЕСТЬNULL(ЗначенияСвойстОбъектовОтборИдТехники.Значение, 0) КАК ИдТехники,
		|	РасходГСМТракторы.РасходГСМПоФакту1С КАК РасходГСМПоФакту1С
		|ПОМЕСТИТЬ ИтоговыеДанные
		|ИЗ
		|	РасходГСМТракторы КАК РасходГСМТракторы
		|		ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|			ЗначенияСвойствОбъектов.Объект КАК Объект,
		|			МАКСИМУМ(ЗначенияСвойствОбъектов.Значение) КАК Значение
		|		ИЗ
		|			РегистрСведений.ЗначенияСвойствОбъектов КАК ЗначенияСвойствОбъектов
		|		ГДЕ
		|			ЗначенияСвойствОбъектов.Свойство = &Свойство
		|		
		|		СГРУППИРОВАТЬ ПО
		|			ЗначенияСвойствОбъектов.Объект) КАК ЗначенияСвойстОбъектовОтборИдТехники
		|		ПО РасходГСМТракторы.Техника = ЗначенияСвойстОбъектовОтборИдТехники.Объект
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	РасходГСМАвтомобили.Техника,
		|	РасходГСМАвтомобили.ТрактористВодитель,
		|	РасходГСМАвтомобили.РасходГСМПоНорме1С,
		|	ЕСТЬNULL(ЗначенияСвойстОбъектовОтборИдТехники.Значение, 0),
		|	РасходГСМАвтомобили.РасходГСМПоФакту1С
		|ИЗ
		|	РасходГСМАвтомобили КАК РасходГСМАвтомобили
		|		ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|			ЗначенияСвойствОбъектов.Объект КАК Объект,
		|			МАКСИМУМ(ЗначенияСвойствОбъектов.Значение) КАК Значение
		|		ИЗ
		|			РегистрСведений.ЗначенияСвойствОбъектов КАК ЗначенияСвойствОбъектов
		|		ГДЕ
		|			ЗначенияСвойствОбъектов.Свойство = &Свойство
		|		
		|		СГРУППИРОВАТЬ ПО
		|			ЗначенияСвойствОбъектов.Объект) КАК ЗначенияСвойстОбъектовОтборИдТехники
		|		ПО РасходГСМАвтомобили.Техника = ЗначенияСвойстОбъектовОтборИдТехники.Объект
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	ИтоговыеДанные.Техника,
		|	ИтоговыеДанные.ТрактористВодитель,
		|	ИтоговыеДанные.РасходГСМПоНорме1С,
		|	ИтоговыеДанные.ИдТехники,
		|	ИтоговыеДанные.РасходГСМПоФакту1С,
		|	ЕСТЬNULL(Заправки.Количество, 0) КАК Заправка1С
		|ИЗ
		|	ИтоговыеДанные КАК ИтоговыеДанные
		|		ЛЕВОЕ СОЕДИНЕНИЕ Заправки КАК Заправки
		|		ПО ИтоговыеДанные.Техника = Заправки.Техника
		|			И ИтоговыеДанные.ТрактористВодитель = Заправки.Сотрудник";
	
	Запрос.УстановитьПараметр("НачалоПериода", ДатаНачала);
	Запрос.УстановитьПараметр("КонецПериода", ДатаОкончания);
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("Свойство", ХранениеИдТехники);  
	
	РезультирующаяТЗ = Запрос.Выполнить().Выгрузить();
	
	ОписаниеТиповЧисло = Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(10,2));
	ОписаниеТиповСтрока = Новый ОписаниеТипов("Строка", Новый КвалификаторыСтроки(100));	
	
	РезультирующаяТЗ.Колонки.Добавить("ОстатокНаНачалоСМТ",ОписаниеТиповЧисло);
	РезультирующаяТЗ.Колонки.Добавить("ЗаправакаПоПоказаниямСМТ",ОписаниеТиповЧисло);
	РезультирующаяТЗ.Колонки.Добавить("РасходГСМПоПоказателямСМТ",ОписаниеТиповЧисло);
	РезультирующаяТЗ.Колонки.Добавить("ОстатокНаКонецСМТ",ОписаниеТиповЧисло);
	РезультирующаяТЗ.Колонки.Добавить("СливТопливаПоСМТ",ОписаниеТиповЧисло);
	РезультирующаяТЗ.Колонки.Добавить("НаименованиеТехники",ОписаниеТиповСтрока);
	
	//Создадим подключение HTTP	
	
	Сервер = АдресТелематическогоСервера;	
	Сервер = СтрЗаменить(Сервер,"http://","");	
	Сервер = СтрЗаменить(Сервер,"https://","");	
	HTTP =  Новый HTTPСоединение(Сервер,ПортТелематическогоСервера);
	
	//Токен = "f6d3b150f3a27f440a91eb22c574343cC523D64898F815969C43E026A5416A761C882B59";
	//f6d3b150f3a27f440a91eb22c574343c36A74771B24C3E78C2953D6FDE5E861237E3D564
	//f6d3b150f3a27f440a91eb22c574343cC523D64898F815969C43E026A5416A761C882B59
	//Токен = "f6d3b150f3a27f440a91eb22c574343cD22B18F7157BCE4094D0F48AA580DD8A87068958";
	
	//получим sid	
	иТекстЗапроса = "/wialon/ajax.html?svc=token/login&params={token:""" + Токен + """}";
	ЗапросКСерверу = Новый HTTPЗапрос(иТекстЗапроса);
	Ответ = HTTP.Получить(ЗапросКСерверу);
	Если Ответ.КодСостояния = 200 Тогда
		ОтветСтрока = Ответ.ПолучитьТелоКакСтроку();
	КонецЕсли;
	
	ПроверитьВозвратСМТ(ОтветСтрока,"Не прошла проверка токена!"); 	
	
	СтрокаEid = Найти(ОтветСтрока,"""eid"":""");
	
	Если СтрокаEid > 0 Тогда
		SessionID = Сред(ОтветСтрока,СтрокаEid+7,32);
	КонецЕсли;
	
	//Установим часовой пояс, смещение времени и язык отчета
	
	часпоясТекстЗапроса = "/wialon/ajax.html?sid=" + SessionID + 
	"&svc=render/set_locale&params={""tzOffset"":" + СмещениеВремениСтрокой + ",""language"":""ru"",""flags"":""""}";
	
	//часпоясТекстЗапроса = "/wialon/ajax.html?sid=" + SessionID + 
	//		"&svc=render/set_locale&params={""tzOffset"":0,""language"":""ru"",""flags"":""""}";
	
	ЗапросКСерверу = Новый HTTPЗапрос(часпоясТекстЗапроса);
	Ответ = HTTP.Получить(ЗапросКСерверу);
	Если Ответ.КодСостояния = 200 Тогда
		ОтветСтрока = Ответ.ПолучитьТелоКакСтроку();
		Если СокрЛП(ОтветСтрока) = "{}" Тогда
			//Сообщить("Смещение времени установлено");
		Иначе
			Сообщить("Ошибка при установке смещении времени");
		КонецЕсли;
	Иначе
		Сообщить("Ошибка при установке смещении времени");   		
	КонецЕсли;
	
	Ит = 0;
	
	Для каждого Стр Из РезультирующаяТЗ Цикл 
		
		ИдТехники = Стр.ИдТехники;
		
		Если ИдТехники = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		Ит = Ит + 1;
		
		//получим даныне по какой-то технике  (текущая дата)  	
		техТекстЗапроса1 = "/wialon/ajax.html?sid=" + SessionID + 
		"&svc=report/exec_report&params={""reportResourceId"":13856467,""reportTemplateId"":4,""reportObjectId"":" + 
		СокрЛП(ИдТехники) + ",""reportObjectSecId"":0,""interval"":{""from"":0,""to"":1,""flags"":0x02}} """;
		//
		//за указанное время 
		ДатаНачалаСМТ = СокрЛП(СтрЗаменить(ДатаНачала + СмещениеВремени - Дата(1970,1,1,0,0,0),Символы.НПП,""));
		ДатаОкончанияСМТ = СокрЛП(СтрЗаменить(ДатаОкончания + СмещениеВремени - Дата(1970,1,1,0,0,0),Символы.НПП,""));
		техТекстЗапроса = "/wialon/ajax.html?sid=" + SessionID + 
		"&svc=report/exec_report&params={""reportResourceId"":"+ИдОтчетаДляПолученияДанных+",""reportTemplateId"":" + ИдШаблонаДляПолученияДанных + ",""reportObjectId"":" + 
		СокрЛП(ИдТехники) + ",""reportObjectSecId"":0,""interval"":{""from"":" + ДатаНачалаСМТ + 
		",""to"":" + ДатаОкончанияСМТ + ",""flags"":0x00}} """;
		
		ЗапросКСерверу = Новый HTTPЗапрос(техТекстЗапроса);
		Ответ = HTTP.Получить(ЗапросКСерверу);
		Если Ответ.КодСостояния = 200 Тогда
			ОтветСтрока = Ответ.ПолучитьТелоКакСтроку();
		КонецЕсли;
		
		Если Найти(ОтветСтрока,"{""error"":7}") > 0 Тогда
			//Ошибка доступа, скорее всего id с другой СМТ
			Продолжить;
		КонецЕсли;
		
		ПроверитьВозвратСМТ(ОтветСтрока,"Ошибка при получении данных по технике "+СокрЛП(Стр.Техника));
		
		Результат = ОтветСтрока;  
		
		///////******************************РАБОТАЕТ ТОЛЬКО НА 8.3**********************************
		//	ЧтениеJSON = Новый ЧтениеJSON;
		//	ЧтениеJSON.УстановитьСтроку(ОтветСтрока);
		//	ОбъектДанных = ПрочитатьJSON(ЧтениеJSON);
		//	
		//	Если ОбъектДанных.Свойство("reportResult") Тогда
		//		
		//		РезультатОтчета = ОбъектДанных["reportResult"];
		//		
		//		Если РезультатОтчета.Свойство("stats") Тогда
		//			
		//			СтатистикаОтчета = РезультатОтчета["stats"];
		//			
		//			//Обход массива
		//			Для Каждого ЭлМассива Из СтатистикаОтчета Цикл
		//				
		//				ПолеОтчета = ЭлМассива[0];
		//				ЗначениеОтчета = ЭлМассива[1];
		//				
		//				Если ПолеОтчета = "Нач. уровень" Тогда
		//					Стр.ОстатокНаНачалоСМТ = ЗначениеОтчета;
		//				ИначеЕсли ПолеОтчета = "Всего заправлено" Тогда
		//					Стр.ЗаправакаПоПоказаниямСМТ = ЗначениеОтчета;
		//				ИначеЕсли ПолеОтчета = "Потрачено по ДУТ" Тогда
		//					Стр.РасходГСМПоПоказателямСМТ = ЗначениеОтчета;
		//				ИначеЕсли ПолеОтчета = "Конеч. уровень" Тогда
		//					Стр.ОстатокНаКонецСМТ = ЗначениеОтчета;
		//				ИначеЕсли ПолеОтчета = "Всего топлива слито" Тогда
		//					Стр.СливТопливаПоСМТ = ЗначениеОтчета; 
		//				КонецЕсли;
		//				
		//			КонецЦикла;
		//			
		//		КонецЕсли;   		
		//		
		//	КонецЕсли; 		
		//	
		
		//находим статистику и обрезаем ненужные данные  		
		ПозицияСтатистики = Найти(Результат,"""stats"":");  		
		Если ПозицияСтатистики > 0 Тогда
			СтрокаСтатистика = Прав(Результат,СтрДлина(Результат)-ПозицияСтатистики);  		
			ПозицияСледующегоОбъекта = Найти(СтрокаСтатистика,"}");		
			СтрокаСтатистика = Лев(СтрокаСтатистика,ПозицияСледующегоОбъекта);  		
		КонецЕсли; 	
		
		//1. Ищем поле "Нач. уровень" (12 символов)
		Стр.ОстатокНаНачалоСМТ = ПолучитьЗначениеИзСтатистики(СтрокаСтатистика,"Нач. уровень",12);
		
		//2. Ищем поле "Всего заправлено" (16 символов)
		Стр.ЗаправакаПоПоказаниямСМТ = ПолучитьЗначениеИзСтатистики(СтрокаСтатистика,"Всего заправлено",16);
		
		//3. Ищем поле "Потрачено по ДУТ"  (16 символов)
		Стр.РасходГСМПоПоказателямСМТ = ПолучитьЗначениеИзСтатистики(СтрокаСтатистика,"Потрачено по ДУТ",16);
		
		//4. Ищем поле "Конеч. уровень" (14 символов) 
		Стр.ОстатокНаКонецСМТ = ПолучитьЗначениеИзСтатистики(СтрокаСтатистика,"Конеч. уровень",14);
		
		//5. Ищем поле "Всего топлива слито"  (19 символов)
		Стр.СливТопливаПоСМТ = ПолучитьЗначениеИзСтатистики(СтрокаСтатистика,"Всего топлива слито",19); 
		
		//***********ДОБАВЛЯЕМ НАИМЕНОВАНИЕ ТЕХНИКИ ДЛЯ СВЯЗИ С ТАБЛИЦОЙ ЗАПРАВОК***********
		//5. Ищем поле "Объект"  (6 символов)
		Стр.НаименованиеТехники = ПолучитьЗначениеИзСтатистики(СтрокаСтатистика,"Объект",6,Истина); 
		
	КонецЦикла;
	
	//Сообщить(Ит);
	
	Возврат РезультирующаяТЗ;
	
КонецФункции

Функция ПолучитьЗначениеИзСтатистики(ИсходнаяСтрока,СтрокаПоиска,ДлинаСтрокиПоиска,ИскатьСтроку = Ложь)
	
	ВозвращаемоеЧисло = 0;
	
	НайденнаяПозиция = Найти(ИсходнаяСтрока,СтрокаПоиска);
	
	Если НайденнаяПозиция > 0 Тогда		
		ОбрезаннаяСтрока = Прав(ИсходнаяСтрока,СтрДлина(ИсходнаяСтрока) - НайденнаяПозиция - ДлинаСтрокиПоиска-2); //добавляем 2, чтобы исключить ковычку с запятйо (",)
		ПозКвадратнойСкобки = Найти(ОбрезаннаяСтрока,"]");
		ОбрезаннаяСтрока = Лев(ОбрезаннаяСтрока,ПозКвадратнойСкобки);
		
		Если ИскатьСтроку Тогда
			СодержимоеСтроки = Лев(ОбрезаннаяСтрока,СтрДлина(ОбрезаннаяСтрока)-2);
			Возврат СодержимоеСтроки;
		КонецЕсли;
		
		МаскаЧисел = "0123456789.,";
		ЗначениеЧисло = "";
		Для Ит = 1 По СтрДлина(ОбрезаннаяСтрока) Цикл
			Если Найти(МаскаЧисел,Сред(ОбрезаннаяСтрока,Ит,1)) > 0 Тогда
				ЗначениеЧисло = ЗначениеЧисло + Сред(ОбрезаннаяСтрока,Ит,1);
			КонецЕсли;
		КонецЦикла;
		ВозвращаемоеЧисло = Число(ЗначениеЧисло);  
		
	КонецЕсли;  
	
	Возврат ВозвращаемоеЧисло;
		
КонецФункции

// <Описание процедуры>
//
// Параметры
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//
Процедура ПроверитьВозвратСМТ(ОтветСтрока,ПроверяемыйПараметр)
	
	Если Найти(ОтветСтрока,"error") > 0 Тогда
		ВызватьИсключение("Не удалось подключиться к системе мониторинга! "+ПроверяемыйПараметр);
	КонецЕсли;   	

КонецПроцедуры // ПроверитьВозвратСМТ()


// Сохраняет текущие настройки отчета
//
Процедура СохранитьНастройку() Экспорт

	СтруктураНастроек = ТиповыеОтчеты.ПолучитьСтруктуруПараметровТиповогоОтчета(ЭтотОбъект);
	СохранениеНастроек.СохранитьНастройкуОбъекта(СохраненнаяНастройка, СтруктураНастроек);
	
КонецПроцедуры

// Применяет текущие настройки отчета
//
Процедура ПрименитьНастройку() Экспорт
	
	Схема = ТиповыеОтчеты.ПолучитьСхемуКомпоновкиОбъекта(ЭтотОбъект);

	// Считываение структуры настроек отчета
 	Если Не СохраненнаяНастройка.Пустая() Тогда
		
		СтруктураНастроек = СохраненнаяНастройка.ХранилищеНастроек.Получить();
		Если Не СтруктураНастроек = Неопределено Тогда
			КомпоновщикНастроек.ЗагрузитьНастройки(СтруктураНастроек.НастройкиКомпоновщика);
			ЗаполнитьЗначенияСвойств(ЭтотОбъект, СтруктураНастроек);
		Иначе
			КомпоновщикНастроек.ЗагрузитьНастройки(Схема.НастройкиПоУмолчанию);
		КонецЕсли;
		
	Иначе
		КомпоновщикНастроек.ЗагрузитьНастройки(Схема.НастройкиПоУмолчанию);
	КонецЕсли;

КонецПроцедуры

// Получает текущие настройки отчета
//
Функция ПолучитьПараметрыИсполненияОтчета() Экспорт
	
	СтруктураНатроек = Новый Структура();
	Возврат СтруктураНатроек;
	
КонецФункции

#КонецЕсли

#Если Клиент Тогда
	
// Настройка отчета при отработки расшифровки
Процедура Настроить(Отбор) Экспорт
	
	// Настройка отбора
	Для каждого ЭлементОтбора Из Отбор Цикл
		
		Если ТипЗнч(ЭлементОтбора) = Тип("ЭлементОтбораКомпоновкиДанных") Тогда
			ПолеОтбора = ЭлементОтбора.ЛевоеЗначение;
		Иначе
			ПолеОтбора = Новый ПолеКомпоновкиДанных(ЭлементОтбора.Поле);
		КонецЕсли;
		
		Если КомпоновщикНастроек.Настройки.ДоступныеПоляОтбора.НайтиПоле(ПолеОтбора) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		НовыйЭлементОтбора = КомпоновщикНастроек.Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		Если ТипЗнч(ЭлементОтбора) = Тип("ЭлементОтбораКомпоновкиДанных") Тогда
			ЗаполнитьЗначенияСвойств(НовыйЭлементОтбора, ЭлементОтбора);
		Иначе
			НовыйЭлементОтбора.Использование  = Истина;
			НовыйЭлементОтбора.ЛевоеЗначение  = ПолеОтбора;
			Если ЭлементОтбора.Иерархия Тогда
				Если ТипЗнч(ЭлементОтбора.Значение) = Тип("СписокЗначений") Тогда
					НовыйЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.ВСпискеПоИерархии;
				Иначе
					НовыйЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.ВИерархии;
				КонецЕсли;
			Иначе
				Если ТипЗнч(ЭлементОтбора.Значение) = Тип("СписокЗначений") Тогда
					НовыйЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.ВСписке;
				Иначе
					НовыйЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
				КонецЕсли;
			КонецЕсли;
			
			НовыйЭлементОтбора.ПравоеЗначение = ЭлементОтбора.Значение;
			
		КонецЕсли;
				
	КонецЦикла;
	
	ТиповыеОтчеты.УдалитьДублиОтбора(КомпоновщикНастроек);
	
КонецПроцедуры

#КонецЕсли

// В процедуре можно доработать компоновщик перед выводом в отчет
// Изменения сохранены не будут
Процедура ДоработатьКомпоновщикПередВыводом() Экспорт
	
	ПараметрНачалоПериода = КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("НачалоПериода"));
	Если ПараметрНачалоПериода <> Неопределено Тогда
		ПараметрНачалоПериода.Использование = Истина;
	КонецЕсли;
	
	ПараметрКонецПериода = КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("КонецПериода"));
	Если ПараметрКонецПериода <> Неопределено Тогда
		ПараметрКонецПериода.Использование = Истина;
	КонецЕсли;
	
	ПараметрОрганизация = КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("Организация"));
	Если ПараметрОрганизация <> Неопределено Тогда
		ПараметрОрганизация.Использование = Истина;
	КонецЕсли;
	
	//СписокРазделовУчета = Новый СписокЗначений;
	//СписокРазделовУчета.Добавить(Перечисления.РазделыУчета.МПЗ);
	//СписокРазделовУчета.Добавить(Перечисления.РазделыУчета.ТоварыОтгруженные);
	//СписокРазделовУчета.Добавить(Перечисления.РазделыУчета.МатериалыВЭксплуатации);
	//
	//ПараметрРазделыУчета = КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("РазделыУчета"));
	//Если ПараметрРазделыУчета <> Неопределено Тогда
	//	ПараметрРазделыУчета.Значение = СписокРазделовУчета;
	//	ПараметрРазделыУчета.Использование = Истина;
	//КонецЕсли;
	
КонецПроцедуры // ДоработатьКомпоновщикПередВыводом()
Если СохраненнаяНастройка = Неопределено Тогда
	СохраненнаяНастройка =  Справочники.СохраненныеНастройки.ПустаяСсылка();
КонецЕсли;
