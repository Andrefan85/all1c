﻿Перем СохраненнаяНастройка Экспорт;        // Текущий вариант отчета

Перем ТаблицаВариантовОтчета Экспорт;      // Таблица вариантов доступных текущему пользователю

#Если Клиент ИЛИ ВнешнееСоединение Тогда
	
Функция СформироватьОтчет(Результат = Неопределено, ДанныеРасшифровки = Неопределено, ВыводВФормуОтчета = Истина) Экспорт
	
	//ЗначениеПанелипользователя = ТиповыеОтчеты.ПолучитьЗначенияНастроекПанелиПользователяОбъекта(ЭтотОбъект);
	НастройкаПоУмолчанию        = КомпоновщикНастроек.ПолучитьНастройки();
	ТиповыеОтчеты.ПолучитьПримененуюНастройку(ЭтотОбъект);
	НастройкиКомпоновщика        = ЭтотОбъект.КомпоновщикНастроек.ПолучитьНастройки();
	
	Если НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("КонецПериода") <> Неопределено Тогда
		ПараметрКонецПериода = НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("КонецПериода").Значение;  	
	КонецЕсли;
	
	
	Если НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ГодУрожая") <> Неопределено Тогда
		ПараметрГодУрожая = НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ГодУрожая").Значение;  	
	КонецЕсли;
	
	
		//определим самый старший год урожая и последующие 5 значений
		
		 	//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	цГодыУрожая.Ссылка КАК Ссылка,
		|	цГодыУрожая.Представление
		|ИЗ
		|	Справочник.цГодыУрожая КАК цГодыУрожая
		|
		|УПОРЯДОЧИТЬ ПО
		|	Ссылка УБЫВ";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	ОписаниеТиповЧисло = Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(4,0));
	
	ТЗЧисел = Новый ТаблицаЗначений;
	ТЗЧисел.Колонки.Добавить("ГодУрожаяЧисло",ОписаниеТиповЧисло);
	ТЗЧисел.Колонки.Добавить("ГодУрожаяСправочник");
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		// Вставить обработку выборки ВыборкаДетальныеЗаписи
		Попытка
			Если Число(ПараметрГодУрожая.Код) > Число(ВыборкаДетальныеЗаписи.Представление) Тогда
				Нстр = ТЗЧисел.Добавить();
				Нстр.ГодУрожаяЧисло = Число(ВыборкаДетальныеЗаписи.Представление);
				Нстр.ГодУрожаяСправочник = ВыборкаДетальныеЗаписи.Ссылка;
				
			КонецЕсли;
			
		Исключение
			Продолжить;
		КонецПопытки;  		
		
	КонецЦикла;
	
	Если ТЗЧисел.Количество() > 0 Тогда
		
		ТЗЧисел.Сортировать("ГодУрожаяЧисло УБЫВ");
		//Первый год
		Если  НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодОдин") <> Неопределено Тогда
			НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодОдин").Значение = 
				?(ТЗЧисел.Количество()>0,ТЗЧисел[0].ГодУрожаяСправочник,Справочники.цГодыУрожая.ПустаяСсылка());
			НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодОдин").Использование = Истина; 
			Если СхемаКомпоновкиДанных.НаборыДанных.ОтборБезПустыхСтрок.Поля.Найти("КультураПредшественникОдинГод") <> Неопределено Тогда
				СхемаКомпоновкиДанных.НаборыДанных.ОтборБезПустыхСтрок.Поля.Найти("КультураПредшественникОдинГод").Заголовок = "Культура-предшественник "+ ТЗЧисел[0].ГодУрожаяСправочник;
			КонецЕсли;		КонецЕсли;
		//Второй год
		Если  НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодДва") <> Неопределено Тогда
			НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодДва").Значение =
				?(ТЗЧисел.Количество()>1,ТЗЧисел[1].ГодУрожаяСправочник,Справочники.цГодыУрожая.ПустаяСсылка());
			НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодДва").Использование = Истина;
			Если СхемаКомпоновкиДанных.НаборыДанных.ОтборБезПустыхСтрок.Поля.Найти("КультураПредшественникДваГода") <> Неопределено Тогда
				СхемаКомпоновкиДанных.НаборыДанных.ОтборБезПустыхСтрок.Поля.Найти("КультураПредшественникДваГода").Заголовок = "Культура-предшественник "+ ТЗЧисел[1].ГодУрожаяСправочник;
			КонецЕсли;
		КонецЕсли;
		//Первый год
		Если  НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодТри") <> Неопределено Тогда
			НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодТри").Значение = 
				?(ТЗЧисел.Количество()>2,ТЗЧисел[2].ГодУрожаяСправочник,Справочники.цГодыУрожая.ПустаяСсылка());
			НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодТри").Использование = Истина;  
			Если СхемаКомпоновкиДанных.НаборыДанных.ОтборБезПустыхСтрок.Поля.Найти("КультураПредшественникТриГода") <> Неопределено Тогда
				СхемаКомпоновкиДанных.НаборыДанных.ОтборБезПустыхСтрок.Поля.Найти("КультураПредшественникТриГода").Заголовок = "Культура-предшественник "+ ТЗЧисел[2].ГодУрожаяСправочник;
			КонецЕсли;
		КонецЕсли;
		//Первый год
		Если  НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодЧетыре") <> Неопределено Тогда
			НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодЧетыре").Значение = 
				?(ТЗЧисел.Количество()>3,ТЗЧисел[3].ГодУрожаяСправочник,Справочники.цГодыУрожая.ПустаяСсылка());
			НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодЧетыре").Использование = Истина; 
			Если СхемаКомпоновкиДанных.НаборыДанных.ОтборБезПустыхСтрок.Поля.Найти("КультураПредшественникЧетыреГод") <> Неопределено Тогда
				СхемаКомпоновкиДанных.НаборыДанных.ОтборБезПустыхСтрок.Поля.Найти("КультураПредшественникЧетыреГод").Заголовок = "Культура-предшественник "+ ТЗЧисел[3].ГодУрожаяСправочник;
			КонецЕсли;
		КонецЕсли;
		//Первый год
		Если  НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодПять") <> Неопределено Тогда
			НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодПять").Значение = 
			?(ТЗЧисел.Количество()>4,ТЗЧисел[4].ГодУрожаяСправочник,Справочники.цГодыУрожая.ПустаяСсылка());
			НастройкиКомпоновщика.ПараметрыДанных.Элементы.Найти("ПредыдущийГодПять").Использование = Истина; 
			Если СхемаКомпоновкиДанных.НаборыДанных.ОтборБезПустыхСтрок.Поля.Найти("КультураПредшественникПятьЛет") <> Неопределено Тогда
				СхемаКомпоновкиДанных.НаборыДанных.ОтборБезПустыхСтрок.Поля.Найти("КультураПредшественникПятьЛет").Заголовок = "Культура-предшественник "+ ТЗЧисел[4].ГодУрожаяСправочник;
			КонецЕсли;
		КонецЕсли; 					
			
	КонецЕсли;  	
	//rav-
	
	КомпоновщикНастроек.ЗагрузитьНастройки(НастройкиКомпоновщика);
	
	ТиповыеОтчеты.СформироватьТиповойОтчет(ЭтотОбъект, Результат, ДанныеРасшифровки, ВыводВФормуОтчета);
	
	//ЭтотОбъект.КомпоновщикНастроек.ПолучитьНастройки().ПараметрыДанных.Элементы["ПредыдущийГодОдин"]
		
КонецФункции

Процедура СохранитьНастройку() Экспорт

	СтруктураНастроек = ТиповыеОтчеты.ПолучитьСтруктуруПараметровТиповогоОтчета(ЭтотОбъект);
	СохранениеНастроек.СохранитьНастройкуОбъекта(СохраненнаяНастройка, СтруктураНастроек);
	
КонецПроцедуры

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

//Процедура ПередВыводомЭлементРезультата(МакетКомпоновки, ПроцессорКомпоновки, ЭлементРезультата) Экспорт
//КонецПроцедуры

//Процедура ПередВыводомОтчета(МакетКомпоновки, ПроцессорКомпоновки) Экспорт
//КонецПроцедуры

//Процедура ПриВыводеЗаголовкаОтчета(ОбластьЗаголовок) Экспорт
//КонецПроцедуры

Функция ПолучитьПараметрыИсполненияОтчета() Экспорт
	СтруктураНатроек = Новый Структура();
	//СтруктураНатроек.Вставить("ИспользоватьСобытияПриФормированииОтчета", истина);
	//СтруктураНатроек.Вставить("ПриВыводеЗаголовкаОтчета",                 истина);
	//СтруктураНатроек.Вставить("ПослеВыводаПанелиПользователя",            истина);
	//СтруктураНатроек.Вставить("ПослеВыводаПериода",                       истина);
	//СтруктураНатроек.Вставить("ПослеВыводаПараметра",                     истина);
	//СтруктураНатроек.Вставить("ПослеВыводаГруппировки",                   истина);
	//СтруктураНатроек.Вставить("ПослеВыводаОтбора",                        истина);
	//СтруктураНатроек.Вставить("ДействияПанелиИзменениеФлажкаДопНастроек", истина);
	//СтруктураНатроек.Вставить("ПриПолучениеНастроекПользователя",         истина);
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

Процедура ДоработатьКомпоновщикПередВыводом() Экспорт
	
КонецПроцедуры

Если СохраненнаяНастройка = Неопределено Тогда
	СохраненнаяНастройка =  Справочники.СохраненныеНастройки.ПустаяСсылка();
КонецЕсли;
