﻿
//Функция собирает данные по документам основания
//
Функция СобратьДанныеТабличныхЧастейДляПечати(Ссылка)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент" , Ссылка);
	Запрос.Текст = "ВЫБРАТЬ
	               |	1 КАК ID,
	               |	МИНИМУМ(СчетФактураВыданныйТовары.НомерСтроки) КАК НомерСтроки,
	               |	СчетФактураВыданныйТовары.Номенклатура,
	               |	СчетФактураВыданныйТовары.Номенклатура.КоэффициентРасчетаОблагаемойБазыАкциза КАК КоэффициентРасчетаОблагаемойБазыАкциза,
	               |	СчетФактураВыданныйТовары.ЕдиницаИзмерения,
	               |	СУММА(СчетФактураВыданныйТовары.Количество) КАК Количество,
	               |	СчетФактураВыданныйТовары.СтавкаАкциза КАК СтавкаАкциза,
	               |	СчетФактураВыданныйТовары.СтавкаНДС,
				   |	СчетФактураВыданныйТовары.Цена,
	               |	СУММА(СчетФактураВыданныйТовары.СуммаАкциза) КАК Акциз,
	               |	СУММА(СчетФактураВыданныйТовары.СуммаНДС) КАК НДС,	               
	               |	СУММА(СчетФактураВыданныйТовары.Сумма) КАК Сумма	               
	               |ИЗ
	               |	Документ.СчетФактураВыданный.Товары КАК СчетФактураВыданныйТовары
	               |ГДЕ
	               |	СчетФактураВыданныйТовары.Ссылка = &ТекущийДокумент
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	СчетФактураВыданныйТовары.Номенклатура,
	               |	СчетФактураВыданныйТовары.ЕдиницаИзмерения,
	               |	СчетФактураВыданныйТовары.СтавкаАкциза,
	               |	СчетФактураВыданныйТовары.СтавкаНДС,
				   |	СчетФактураВыданныйТовары.Цена				   
	               |
	               |ОБЪЕДИНИТЬ ВСЕ
	               |
	               |ВЫБРАТЬ
	               |	2,
	               |	МИНИМУМ(СчетФактураВыданныйУслуги.НомерСтроки),
	               |	ВЫБОР
	               |		КОГДА (НЕ СчетФактураВыданныйУслуги.Содержание = """")
	               |			ТОГДА СчетФактураВыданныйУслуги.Содержание
	               |		ИНАЧЕ СчетФактураВыданныйУслуги.Номенклатура
	               |	КОНЕЦ,
	               |	СУММА(0),
	               |	СчетФактураВыданныйУслуги.Номенклатура.БазоваяЕдиницаИзмерения,
	               |	СУММА(СчетФактураВыданныйУслуги.Количество),
	               |	СУММА(0),
	               |	СчетФактураВыданныйУслуги.СтавкаНДС,
	               |	СчетФактураВыданныйУслуги.Цена,
				   |	СУММА(0),
	               |	СУММА(СчетФактураВыданныйУслуги.СуммаНДС),	               
	               |	СУММА(СчетФактураВыданныйУслуги.Сумма)
	               |ИЗ
	               |	Документ.СчетФактураВыданный.Услуги КАК СчетФактураВыданныйУслуги
	               |ГДЕ
	               |	СчетФактураВыданныйУслуги.Ссылка = &ТекущийДокумент
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВЫБОР
	               |		КОГДА (НЕ СчетФактураВыданныйУслуги.Содержание = """")
	               |			ТОГДА СчетФактураВыданныйУслуги.Содержание
	               |		ИНАЧЕ СчетФактураВыданныйУслуги.Номенклатура
	               |	КОНЕЦ,
	               |	СчетФактураВыданныйУслуги.Номенклатура.БазоваяЕдиницаИзмерения,
	               |	СчетФактураВыданныйУслуги.СтавкаНДС,
	               |	СчетФактураВыданныйУслуги.Цена
	               |
	               |ОБЪЕДИНИТЬ ВСЕ
	               |
	               |ВЫБРАТЬ
	               |	3,
	               |	МИНИМУМ(СчетФактураВыданныйОС.НомерСтроки),
	               |	СчетФактураВыданныйОС.ОсновноеСредство,
	               |	СУММА(0),
	               |	""шт"",
	               |	1,
	               |	СУММА(0),
	               |	СчетФактураВыданныйОС.СтавкаНДС,
				   |	СчетФактураВыданныйОС.Сумма,
	               |	СУММА(0),
	               |	СУММА(СчетФактураВыданныйОС.СуммаНДС),
				   |	СУММА(СчетФактураВыданныйОС.Сумма)
	               |ИЗ
	               |	Документ.СчетФактураВыданный.ОС КАК СчетФактураВыданныйОС
	               |ГДЕ
	               |	СчетФактураВыданныйОС.Ссылка = &ТекущийДокумент
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	СчетФактураВыданныйОС.ОсновноеСредство,
	               |	СчетФактураВыданныйОС.СтавкаНДС,
				   |	СчетФактураВыданныйОС.Сумма
	               |
	               |ОБЪЕДИНИТЬ ВСЕ
	               |
	               |ВЫБРАТЬ
	               |	4,
	               |	1,
	               |	СчетФактураВыданныйНМА.НематериальныйАктив,
	               |	СУММА(0),
	               |	""шт"",
	               |	1,
	               |	СУММА(0),
	               |	СчетФактураВыданныйНМА.СтавкаНДС,
				   |	СчетФактураВыданныйНМА.Сумма,
	               |	СУММА(0),
	               |	СУММА(СчетФактураВыданныйНМА.СуммаНДС),	               
	               |	СУММА(СчетФактураВыданныйНМА.Сумма)
	               |ИЗ
	               |	Документ.СчетФактураВыданный.НМА КАК СчетФактураВыданныйНМА
	               |ГДЕ
	               |	СчетФактураВыданныйНМА.Ссылка = &ТекущийДокумент
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	СчетФактураВыданныйНМА.НематериальныйАктив,
              	   |	СчетФактураВыданныйНМА.СтавкаНДС,
	               |	СчетФактураВыданныйНМА.Сумма	               
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	ID,
	               |	НомерСтроки";
	ОбщаяТаблицаДляПечати = Запрос.Выполнить().Выгрузить();
	
	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(Ссылка.ПолучитьОбъект());
	
	// используем процедуру общего модуля так как для валютных расчетов могут быть погрешности округления при пересчете по строкам
	УправлениеВзаиморасчетами.ПодготовкаТаблицыЗначенийДляЦелейПриобретенияИРеализации(ОбщаяТаблицаДляПечати, СтруктураШапкиДокумента, Истина);
	
	ДанныеДляПечати = Новый Структура();
	ДанныеДляПечати.Вставить("Организация",      	Ссылка.Организация);
	ДанныеДляПечати.Вставить("Контрагент",       	Ссылка.Контрагент);
	ДанныеДляПечати.Вставить("Номер",            	Ссылка.Номер);
	ДанныеДляПечати.Вставить("Дата",             	Ссылка.Дата);
	ДанныеДляПечати.Вставить("Поставщик",        	Ссылка.Поставщик);
	ДанныеДляПечати.Вставить("Покупатель",       	Ссылка.Покупатель);
	ДанныеДляПечати.Вставить("СтранаНазначения",    Ссылка.СтранаНазначения);
	
	ДанныеДляПечати.Вставить("ДоговорПокупателя",	Ссылка.ДоговорКонтрагента.Наименование);
	ДанныеДляПечати.Вставить("Грузоотправитель", 	Ссылка.Грузоотправитель);
	ДанныеДляПечати.Вставить("Грузополучатель",  	Ссылка.Грузополучатель);
	ДанныеДляПечати.Вставить("УсловияОплаты",    	Ссылка.УсловияОплаты);
	ДанныеДляПечати.Вставить("ПунктНазначения",  	Ссылка.ПунктНазначения);
	ДанныеДляПечати.Вставить("СпособОтправления",	Ссылка.СпособОтправления);
	ДанныеДляПечати.Вставить("СчетОрганизации",  	Ссылка.СчетОрганизации);
	
	Если ЗначениеЗаполнено(Ссылка.Доверенность) Тогда
		ДанныеДляДоверенности = СокрЛП(Ссылка.Доверенность);
		Если ЗначениеЗаполнено(Ссылка.ДоверенностьЧерезКого) Тогда
			ДанныеДляДоверенности = ДанныеДляДоверенности + ", выданной "  + СокрЛП(Ссылка.ДоверенностьЧерезКого);
		КонецЕсли;	
		ДанныеДляПечати.Вставить("Доверенность",     	ДанныеДляДоверенности);
	КонецЕсли;

	ДанныеДляПечати.Вставить("Дополнительная",   	?(Ссылка.ВидСчетаФактуры = Перечисления.ВидыСчетовФактур.Дополнительный, Истина, Ложь));	
	ДанныеДляПечати.Вставить("ОсновнойСчетФактура", Ссылка.ОсновнойСчетФактура);
	ДанныеДляПечати.Вставить("Валюта",           	Ссылка.ВалютаДокумента);
	ДанныеДляПечати.Вставить("ВидСчетаФактуры", 	Ссылка.ВидСчетаФактуры);

	Руководители = ОбщегоНазначения.ОтветственныеЛицаОрганизаций(Ссылка.Организация, Ссылка.Дата, Ссылка.Ответственный);
	ДанныеДляПечати.Вставить("ФИОРуководителя", 	  Руководители.Руководитель);
	ДанныеДляПечати.Вставить("ФИОГлавногоБухгалтера", Руководители.ГлавныйБухгалтер);
	ДанныеДляПечати.Вставить("ФИОИсполнителя", 		  Руководители.Исполнитель);
	ДанныеДляПечати.Вставить("ДолжностьИсполнителя",  Руководители.ИсполнительДолжность);

	ТоварыИн = ИнициализацияТаблицыСтрок();

	НомерСтроки = 1;
	ТолькоУслуги  = Истина;
	Для Каждого СтрокаПечати ИЗ ОбщаяТаблицаДляПечати Цикл

		Строчка = ТоварыИн.Добавить();
		Строчка.НомерСтроки         		 = НомерСтроки;
		Если ТипЗнч(СтрокаПечати.Номенклатура) = Тип(Новый ОписаниеТипов("Строка")) Тогда
			Строчка.ТоварНаименование   		 = СтрокаПечати.Номенклатура;
		Иначе
			Строчка.ТоварНаименование   		 = СтрокаПечати.Номенклатура.НаименованиеПолное;
		КонецЕсли;
		Строчка.ЕдиницаИзмеренияНаименование = ?(СтрокаПечати.ЕдиницаИзмерения = "", "шт", СтрокаПечати.ЕдиницаИзмерения);
		Строчка.Количество 					 = СтрокаПечати.Количество;		
		Строчка.СтоимостьБезНДС            	 = СтрокаПечати.СуммаВал - СтрокаПечати.НДСВал;
		Строчка.СтоимостьБезНДСРегл        	 = СтрокаПечати.Сумма - СтрокаПечати.НДС;
		Строчка.ЦенаБезНДС 					 = Окр(Строчка.СтоимостьБезНДС/?(СтрокаПечати.Количество = 0, 1, СтрокаПечати.Количество), 2);
		Строчка.ЦенаБезНДСРегл 				 = Окр(Строчка.СтоимостьБезНДСРегл/?(СтрокаПечати.Количество = 0, 1, СтрокаПечати.Количество), 2);
		Строчка.СуммаНДС          			 = СтрокаПечати.НДСВал;		
		Строчка.СуммаНДСРегл       			 = СтрокаПечати.НДС;		
		Строчка.СтавкаАкциза				 = СтрокаПечати.СтавкаАкциза;
		Строчка.СуммаАкциза        			 = СтрокаПечати.АкцизВал;
		Строчка.СуммаАкцизаРегл    			 = СтрокаПечати.Акциз;
		Строчка.Всего    					 = СтрокаПечати.СуммаВал;
		Строчка.ВсегоРегл  					 = СтрокаПечати.Сумма;
		НомерСтроки 						 = НомерСтроки+1;
		
		Если ЗначениеЗаполнено(СтрокаПечати.СтавкаНДС) Тогда
			Строчка.СтавкаНДС = ?(СтрокаПечати.СтавкаНДС.ДляОсвобожденногоОборота, "Без НДС", "" + СтрокаПечати.СтавкаНДС.Ставка + "%");
		КонецЕсли;
		Если ТолькоУслуги И ((СтрокаПечати.ID = 1) ИЛИ (СтрокаПечати.ID = 3)) Тогда 
			ТолькоУслуги = ЛОЖЬ;
		КонецЕсли;	
	КонецЦикла;

	ДанныеДляПечати.Вставить("ТабличнаяЧасть", ТоварыИн);
    	
	ТТН = "";
	// В случае реализации товаров, заполняем данные о ТТН
	Если НЕ ТолькоУслуги Тогда		
		ТекущийНомер = 1;
		Для Каждого Основание Из Ссылка.ДокументыОснования Цикл
			Если ЗначениеЗаполнено(Основание.ДокументОснование) Тогда 
				Попытка
					//ПредставлениеДок = РаботаСДиалогами.СформироватьЗаголовокДокумента(Основание.ДокументОснование,,глСписокПрефиксовУзлов);
					ПредставлениеДок = Строка(Основание.ДокументОснование);
				Исключение
					ПредставлениеДок = Строка(Основание.ДокументОснование);
				КонецПопытки;
				ТТН 		 = ТТН + ?(ТекущийНомер = 1, "", ", ") + ПредставлениеДок;
				ТекущийНомер = ТекущийНомер + 1;
			КонецЕсли;
		КонецЦикла; 
	КонецЕсли;
	
	ДанныеДляПечати.Вставить("ТТН", ТТН);	
	ДанныеДляПечати.Вставить("ДатаОборотаПоРеализации", Ссылка.ДатаСовершенияОборотаПоРеализации);	
	
	Возврат ДанныеДляПечати;	
	
КонецФункции

// <Описание функции>
//
// Параметры
//  <Параметр1>  – <Тип.Вид> – <описание параметра>
//                 <продолжение описания параметра>
//  <Параметр2>  – <Тип.Вид> – <описание параметра>
//                 <продолжение описания параметра>
//
// Возвращаемое значение:
//   <Тип.Вид>   – <описание возвращаемого значения>
//
Функция ИнициализацияТаблицыСтрок()

	ТаблицаСтрок = Новый ТаблицаЗначений;
	ТаблицаСтрок.Колонки.Добавить("НомерСтроки");
	ТаблицаСтрок.Колонки.Добавить("ТоварНаименование");
	ТаблицаСтрок.Колонки.Добавить("ЕдиницаИзмеренияНаименование");
	ТаблицаСтрок.Колонки.Добавить("Количество");
	ТаблицаСтрок.Колонки.Добавить("ЦенаБезНДС");
	ТаблицаСтрок.Колонки.Добавить("ЦенаБезНДСРегл");
	ТаблицаСтрок.Колонки.Добавить("СтоимостьБезНДС");
	ТаблицаСтрок.Колонки.Добавить("СтоимостьБезНДСРегл");
	ТаблицаСтрок.Колонки.Добавить("СтавкаНДС");
	ТаблицаСтрок.Колонки.Добавить("СуммаНДС");
	ТаблицаСтрок.Колонки.Добавить("СуммаНДСРегл");
	ТаблицаСтрок.Колонки.Добавить("СтавкаАкциза");
	ТаблицаСтрок.Колонки.Добавить("СуммаАкциза");
	ТаблицаСтрок.Колонки.Добавить("СуммаАкцизаРегл");
	ТаблицаСтрок.Колонки.Добавить("Всего");
	ТаблицаСтрок.Колонки.Добавить("ВсегоРегл");
	
	Возврат ТаблицаСтрок;

КонецФункции // ИнициализацияТаблицыСтрок()

// Процедура осуществляет печать документа. Можно направить печать на 
// экран или принтер, а также распечатать необходмое количество копий.
//
//  Название макета печати передается в качестве параметра,
// по переданному названию находим имя макета в соответствии.
//
// Параметры:
//  НазваниеМакета - строка, название макета.
//
Функция Печать() Экспорт
	
	КоличествоЭкземпляров=1;
 	НаПринтер=Ложь;
 
	ТабДокумент = ПечатьСчетаФактуры(); 
	//ТабДокумент = Новый ТабличныйДокумент;
	
	Если ТабДокумент <> Неопределено Тогда
		//УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(СсылкаНаОбъект, ""), СсылкаНаОбъект);
	КонецЕсли; 
	
	Возврат ТабДокумент;
	
КонецФункции // Печать


Функция ПечатьСчетаФактуры() Экспорт
	
	Ссылка = СсылкаНаОбъект;
	
	ТабДокумент = Новый ТабличныйДокумент;
	
	ВВалютеРеглУчета = Ложь;
	ДанныеДляПечатиПоУчастникамСовместнойДеятельности = Неопределено;
	
	ДанныеДляПечати = СобратьДанныеТабличныхЧастейДляПечати(Ссылка);

	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_СчетФактураВыданный_СчетФактура";
	Макет = ПолучитьМакет("СчетФактура");
	
	СведенияОПокупателе = ОбщегоНазначения.СведенияОЮрФизЛице(ДанныеДляПечати.Покупатель, Ссылка.Дата, , );
	СведенияОПоставщике  = ОбщегоНазначения.СведенияОЮрФизЛице(ДанныеДляПечати.Поставщик, Ссылка.Дата, , Ссылка.СчетОрганизации);
	
	СведенияОГрузоотправителе = Новый Структура;
	Если ЗначениеЗаполнено(ДанныеДляПечати.Грузоотправитель) Тогда
		СведенияОГрузоотправителе = ОбщегоНазначения.СведенияОЮрФизЛице(ДанныеДляПечати.Грузоотправитель, Ссылка.Дата);
	КонецЕсли;	
	
	СведенияОГрузополучателе = Новый Структура;
	Если ЗначениеЗаполнено(ДанныеДляПечати.Грузополучатель) Тогда
		СведенияОГрузополучателе = ОбщегоНазначения.СведенияОЮрФизЛице(ДанныеДляПечати.Грузополучатель, Ссылка.Дата);
	КонецЕсли;	

	// Выводим шапку накладной
	ТекстДополнительныйИлиИсправленныйСчетФактура = "";
	Если ДанныеДляПечати.Дополнительная Тогда
		ТекстДополнительныйИлиИсправленныйСчетФактура = "Дополнительный счет-фактура" + ?(ЗначениеЗаполнено(ДанныеДляПечати.ОсновнойСчетФактура), " к " + 
		"счету-фактуре №" + ОбщегоНазначения.ПолучитьНомерНаПечать(ДанныеДляПечати.ОсновнойСчетФактура) + " от " + Формат(ДанныеДляПечати.ОсновнойСчетФактура.Дата,"ДФ=dd.MM.yyyy" ),"");
	ИначеЕсли ДанныеДляПечати.ВидСчетаФактуры = Перечисления.ВидыСчетовФактур.Исправленный Тогда
		ТекстДополнительныйИлиИсправленныйСчетФактура = "Исправленный счет-фактура" + ?(ЗначениеЗаполнено(ДанныеДляПечати.ОсновнойСчетФактура), " к " + 
		"счету-фактуре №" + ОбщегоНазначения.ПолучитьНомерНаПечать(ДанныеДляПечати.ОсновнойСчетФактура) + " от " + Формат(ДанныеДляПечати.ОсновнойСчетФактура.Дата,"ДФ=dd.MM.yyyy" ),"");
	КонецЕсли;
	
	ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
	ОбластьМакета.Параметры.ДополнительныйИлиИсправленныйСчетФактура = ТекстДополнительныйИлиИсправленныйСчетФактура;
	ОбластьМакета.Параметры.Заполнить(ДанныеДляПечати);
	// Строку даты оборота по реализации выводим только если реализации в РФ или РБ
	Если Ссылка.Дата<Дата(2010,7,1) ИЛИ НЕ ЗначениеЗаполнено(Ссылка.СтранаНазначения.УчастникТаможенногоСоюза) Тогда
		ОбластьМакета.Область("ДатаОборотаПоРеализации").Видимость = Ложь;	
	Иначе
		ОбластьМакета.Параметры.ДатаОборотаПоРеализации = Формат(ДанныеДляПечати.ДатаОборотаПоРеализации, "ДФ=dd.MM.yyyy");				
	КонецЕсли;
	
	//ОбластьМакета.Параметры.Номер = РаботаСДиалогами.СформироватьЗаголовокДокумента(ЭтотОбъект, "Счет-фактура", глСписокПрефиксовУзлов);
	ОбластьМакета.Параметры.Номер = "Счет-фактура выданный № " + СокрЛП(СсылкаНаОбъект.Номер)
						+ " от " + Формат(СсылкаНаОбъект.Дата, "ДЛФ=DD");

	ОбластьМакета.Параметры.ПредставлениеПоставщика = ОбщегоНазначения.ОписаниеОрганизации(СведенияОПоставщике, "ПолноеНаименование,");
	
	СвидетельствоПоНДС = СокрЛП(ОбщегоНазначения.ОписаниеОрганизации(СведенияОПоставщике, "СвидетельствоПоНДС,"));
	ОбластьМакета.Параметры.СвидетельствоПоНДС = "Серия и номер свидетельства о постановке на регистрационный учет по НДС, "+ СвидетельствоПоНДС;
	
	//Реквизиты поставщика
	ПредставлениеРНН_БИНПоставщика = "";
	РННиБИНПоставщика = ОбщегоНазначения.ПолучитьРегистрационныйНомерОрганизацииКонтрагентаВПечатнуюФорму(СведенияОПоставщике, Ссылка.Дата, Истина, ПредставлениеРНН_БИНПоставщика, , Истина);		
	ОбластьМакета.Параметры.РННИАдресПоставщика 		   = РННиБИНПоставщика  + ", " +  ОбщегоНазначения.ОписаниеОрганизации(СведенияОПоставщике, "ЮридическийАдрес,");
	ОбластьМакета.Параметры.ПредставлениеРНН_БИНПоставщика = ПредставлениеРНН_БИНПоставщика;
	
	ОбластьМакета.Параметры.РасчетныйСчетПоставщика		   = ОбщегоНазначения.ОписаниеОрганизации(СведенияОПоставщике, "НомерСчета,Банк,БИК,");
	
	//Реквизиты грузоотправителя
	ПредставлениеРНН_БИНГрузоотправителя = "";
	РННиБИНГрузоотправителя = ОбщегоНазначения.ПолучитьРегистрационныйНомерОрганизацииКонтрагентаВПечатнуюФорму(СведенияОГрузоотправителе, Ссылка.Дата, Истина, ПредставлениеРНН_БИНГрузоотправителя, , Истина);		
	ОбластьМакета.Параметры.ПредставлениеГрузоотправителя  = РННиБИНГрузоотправителя  + ", " +  ОбщегоНазначения.ОписаниеОрганизации(СведенияОГрузоотправителе, "ПолноеНаименование,ЮридическийАдрес,");
	ОбластьМакета.Параметры.ПредставлениеРНН_БИНГрузоотправителя = ПредставлениеРНН_БИНГрузоотправителя;
		
	//Реквизиты грузополучателя
	ПредставлениеРНН_БИНГрузополучателя = "";
	РННиБИНГрузополучателя = ОбщегоНазначения.ПолучитьРегистрационныйНомерОрганизацииКонтрагентаВПечатнуюФорму(СведенияОГрузополучателе, Ссылка.Дата, Истина, ПредставлениеРНН_БИНГрузополучателя, , Истина);
	ОбластьМакета.Параметры.ПредставлениеГрузополучателя  = РННиБИНГрузополучателя  + ", " +  ОбщегоНазначения.ОписаниеОрганизации(СведенияОГрузополучателе, "ПолноеНаименование,ЮридическийАдрес,");
	ОбластьМакета.Параметры.ПредставлениеРНН_БИНГрузополучателя = ПредставлениеРНН_БИНГрузополучателя;
	
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("ШапкаПокупателя");
	
	Если ДанныеДляПечатиПоУчастникамСовместнойДеятельности = Неопределено Тогда 
		
		ОбластьМакета.Параметры.Получатель = "Получатель";
		ОбластьМакета.Область("РасчетныйСчетПокупателя").Видимость = Истина;	
			
		//Реквизиты покупателя	
		ОбластьМакета.Параметры.ПредставлениеПокупателя 	  = ОбщегоНазначения.ОписаниеОрганизации(СведенияОПокупателе, "ПолноеНаименование,");
		
		//Вывод БИН, если он заполнен		
		ПредставлениеРНН_БИНПокупателя = "";
		РННиБИНПокупателя = ОбщегоНазначения.ПолучитьРегистрационныйНомерОрганизацииКонтрагентаВПечатнуюФорму(СведенияОПокупателе, Ссылка.Дата, Истина, ПредставлениеРНН_БИНПокупателя, , Истина);		
		ОбластьМакета.Параметры.РННИАдресПокупателя = РННиБИНПокупателя  + ", " +  ОбщегоНазначения.ОписаниеОрганизации(СведенияОПокупателе, "ЮридическийАдрес,");
		ОбластьМакета.Параметры.ПредставлениеРНН_БИНПокупателя = ПредставлениеРНН_БИНПокупателя;
		
		ОбластьМакета.Параметры.РасчетныйСчетПокупателя = ОбщегоНазначения.ОписаниеОрганизации(СведенияОПокупателе, "НомерСчета,Банк,БИК,");
		
		ТабДокумент.Вывести(ОбластьМакета);
		
	Иначе 
		ТаблицаУчастниковСовместнойДеятельности = ДанныеДляПечатиПоУчастникамСовместнойДеятельности.Скопировать(, "Покупатель");
		ТаблицаУчастниковСовместнойДеятельности.Свернуть("Покупатель");
		
		Для Каждого Строчка Из ТаблицаУчастниковСовместнойДеятельности Цикл
			
			СведенияОПокупателе = ОбщегоНазначения.СведенияОЮрФизЛице(Строчка.Покупатель,Ссылка.Дата, ,Ссылка.СчетКонтрагента);
			
			Если Строчка.Покупатель = Ссылка.Покупатель Тогда
				
				ОбластьМакета.Параметры.Получатель = "Получатель";
				ОбластьМакета.Область("РасчетныйСчетПокупателя").Видимость = Истина;	
			Иначе
				
				ОбластьМакета.Параметры.Получатель = "Участник совместной деятельности";
				ОбластьМакета.Область("РасчетныйСчетПокупателя").Видимость = Ложь;	
			КонецЕсли;
			
			//Реквизиты покупателя	
			ОбластьМакета.Параметры.ПредставлениеПокупателя = ОбщегоНазначения.ОписаниеОрганизации(СведенияОПокупателе, "ПолноеНаименование,");
			
			//Вывод БИН, если он заполнен		
			ПредставлениеРНН_БИНПокупателя = "";
			РННиБИНПокупателя = ОбщегоНазначения.ПолучитьРегистрационныйНомерОрганизацииКонтрагентаВПечатнуюФорму(СведенияОПокупателе, Ссылка.Дата, Истина, ПредставлениеРНН_БИНПокупателя, , Истина);		
			ОбластьМакета.Параметры.РННИАдресПокупателя = РННиБИНПокупателя  + ", " +  ОбщегоНазначения.ОписаниеОрганизации(СведенияОПокупателе, "ЮридическийАдрес,");
			ОбластьМакета.Параметры.ПредставлениеРНН_БИНПокупателя = ПредставлениеРНН_БИНПокупателя;
			
			ОбластьМакета.Параметры.РасчетныйСчетПокупателя = ОбщегоНазначения.ОписаниеОрганизации(СведенияОПокупателе, "НомерСчета,Банк,БИК,");
			
			ТабДокумент.Вывести(ОбластьМакета);
			
		КонецЦикла;
	КонецЕсли;
	
	ОбластьМакета = Макет.ПолучитьОбласть("ШапкаТаблицы");
	Если ВВалютеРеглУчета Тогда
		мВалютаРегламентированногоУчета   = Константы.ВалютаРегламентированногоУчета.Получить();
		ОбластьМакета.Параметры.Валюта = мВалютаРегламентированногоУчета;
	Иначе
		ОбластьМакета.Параметры.Валюта = Ссылка.ВалютаДокумента;
	КонецЕсли;

	ТабДокумент.Вывести(ОбластьМакета);
	
	ОбластьМакета = Макет.ПолучитьОбласть("Строка");

	ВыборкаСтрокТовары = ДанныеДляПечати.ТабличнаяЧасть;
    ПрефиксПоля  	   = ?(ВВалютеРеглУчета, "Регл", "");
	
	Для Каждого Строчка Из ВыборкаСтрокТовары Цикл
		
		ОбластьМакета.Параметры.Заполнить(Строчка);
		
		ОбластьМакета.Параметры.ЦенаБезНДС 		 = Строчка["ЦенаБезНДС"		 + ПрефиксПоля]; 
		ОбластьМакета.Параметры.СтоимостьБезНДС  = Строчка["СтоимостьБезНДС" + ПрефиксПоля];
		ОбластьМакета.Параметры.СуммаНДС		 = Строчка["СуммаНДС"		 + ПрефиксПоля];	
		ОбластьМакета.Параметры.Всего			 = Строчка["Всего" 			 + ПрефиксПоля];
		ОбластьМакета.Параметры.СуммаАкциза		 = Строчка["СуммаАкциза"	 + ПрефиксПоля];
		
		ТабДокумент.Вывести(ОбластьМакета);

	КонецЦикла;

	ОбластьМакета = Макет.ПолучитьОбласть("Итого");
	ОбластьМакета.Параметры.ИтогоСуммаНДС 			= ВыборкаСтрокТовары.Итог("СуммаНДС" 		+ ПрефиксПоля);
	ОбластьМакета.Параметры.ИтогоСтоимостьБезНДС 	= ВыборкаСтрокТовары.Итог("СтоимостьБезНДС" + ПрефиксПоля);
	ОбластьМакета.Параметры.ИтогоВсего    			= ВыборкаСтрокТовары.Итог("Всего" 			+ ПрефиксПоля);
	ОбластьМакета.Параметры.ИтогоСуммаАкциза 		= ВыборкаСтрокТовары.Итог("СуммаАкциза" 	+ ПрефиксПоля);
	
	ТабДокумент.Вывести(ОбластьМакета);

	Если ДанныеДляПечатиПоУчастникамСовместнойДеятельности <> Неопределено Тогда 
		
		ОбластьМакета = Макет.ПолучитьОбласть("ШапкаТаблицыУчастникиСовместнойДеятельности");
		ТабДокумент.Вывести(ОбластьМакета);
		
		ОбластьМакета = Макет.ПолучитьОбласть("СтрокУчастникиСовместнойДеятельности");
		ПрефиксПоля  = ?(ВВалютеРеглУчета, "Регл", "ВВалютеДоговора");
		НомерСтроки = 0;
		Для Каждого Строчка Из ДанныеДляПечатиПоУчастникамСовместнойДеятельности Цикл
			
			НомерСтроки = НомерСтроки + 1;
			
			ОбластьМакета.Параметры.НомерСтроки		               = НомерСтроки;
			СведенияОПокупателе = ОбщегоНазначения.СведенияОЮрФизЛице(Строчка.Покупатель, Ссылка.Дата);
			
			ОбластьМакета.Параметры.УчастникСовместнойДеятельности = ОбщегоНазначения.ОписаниеОрганизации(СведенияОПокупателе, "ПолноеНаименование,");
			ОбластьМакета.Параметры.ДоляУчастия                    = "" + Строчка.ДоляУчастия + "/" + Строчка.СуммаДолейУчастия;
			ОбластьМакета.Параметры.СтоимостьБезНДС                = Строчка["Сумма" + ПрефиксПоля + "Оборот"];
			ОбластьМакета.Параметры.СтавкаНДС                      = ?(Строчка.СтавкаНДС.ДляОсвобожденногоОборота, "Без НДС", "" + Строчка.СтавкаНДС.Ставка + "%");
			ОбластьМакета.Параметры.СуммаНДС                       = Строчка["СуммаНДС" + ПрефиксПоля + "Оборот"];
			ОбластьМакета.Параметры.Всего	                       = Строчка["Сумма" + ПрефиксПоля + "Оборот"] + Строчка["СуммаНДС" + ПрефиксПоля + "Оборот"];
			
			ОбластьМакета.Параметры.СтавкаАкциза = Строчка.СтавкаАкциза;
			ОбластьМакета.Параметры.СуммаАкциза  = Строчка["СуммаАкциза" + ПрефиксПоля + "Оборот"];
						
			ТабДокумент.Вывести(ОбластьМакета);
			
		КонецЦикла;
		
		ОбластьМакета = Макет.ПолучитьОбласть("ИтогоУчастникиСовместнойДеятельности");
		ОбластьМакета.Параметры.ИтогоСтоимостьБезНДС = ДанныеДляПечатиПоУчастникамСовместнойДеятельности.Итог("Сумма" + ПрефиксПоля + "Оборот");
		ОбластьМакета.Параметры.ИтогоСуммаНДС 		 = ДанныеДляПечатиПоУчастникамСовместнойДеятельности.Итог("СуммаНДС" + ПрефиксПоля + "Оборот");
		ОбластьМакета.Параметры.ИтогоСуммаАкциза     = ДанныеДляПечатиПоУчастникамСовместнойДеятельности.Итог("СуммаАкциза" + ПрефиксПоля + "Оборот");
		ОбластьМакета.Параметры.ИтогоВсего			 = ДанныеДляПечатиПоУчастникамСовместнойДеятельности.Итог("Сумма" + ПрефиксПоля + "Оборот") + ДанныеДляПечатиПоУчастникамСовместнойДеятельности.Итог("СуммаНДС" + ПрефиксПоля + "Оборот");
		
		ТабДокумент.Вывести(ОбластьМакета);
		
	КонецЕсли;
	
	ОбластьМакета = Макет.ПолучитьОбласть("Подвал");
	ОбластьМакета.Параметры.Заполнить(ДанныеДляПечати);
	
	ОбластьМакетаПодтверждение = ОбластьМакета.Область("ПодвалПодтверждениеПолучения");
	Если ДанныеДляПечати.ВидСчетаФактуры = Перечисления.ВидыСчетовФактур.Обычный Тогда
		ОбластьМакетаПодтверждение.Видимость = Ложь;
	КонецЕсли;

	Руководители = ОбщегоНазначения.ОтветственныеЛицаОрганизаций(ДанныеДляПечати.Поставщик, Ссылка.Дата);
	//заполним уполномоченного за главного бухгалтера для подписи счета-фактуры
	Если ЗначениеЗаполнено(Руководители.УполномоченныйПодписыватьСчетаФактурыЗаГлавногоБухгалтера) Тогда
		ДолжностьГлБухгалтера = ?(НЕ ЗначениеЗаполнено(Руководители.УполномоченныйПодписыватьСчетаФактурыЗаГлавногоБухгалтераДолжность), "<Должность не указана>: ", Руководители.УполномоченныйПодписыватьСчетаФактурыЗаГлавногоБухгалтераДолжность + ": ");		
		ОбластьМакета.Параметры.ФИОГлавногоБухгалтера = ДолжностьГлБухгалтера + Руководители.УполномоченныйПодписыватьСчетаФактурыЗаГлавногоБухгалтера;
	Иначе
		ДолжностьГлБухгалтера = "Главный бухгалтер: ";		
		ОбластьМакета.Параметры.ФИОГлавногоБухгалтера = ДолжностьГлБухгалтера + Руководители.ГлавныйБухгалтер;
	КонецЕсли;
	
	//заполним уполномоченного за руководителя для подписи счета-фактуры
	Если ЗначениеЗаполнено(Руководители.УполномоченныйПодписыватьСчетаФактурыЗаРуководителя) Тогда
		ДолжностьРуководителя = ?(НЕ ЗначениеЗаполнено(Руководители.УполномоченныйПодписыватьСчетаФактурыЗаРуководителяДолжность), " ", Руководители.УполномоченныйПодписыватьСчетаФактурыЗаРуководителяДолжность + ": ");		
		ОбластьМакета.Параметры.ФИОРуководителя =  ДолжностьРуководителя + Руководители.УполномоченныйПодписыватьСчетаФактурыЗаРуководителя;
	Иначе
		ДолжностьРуководителя = "Руководитель: ";		
		ОбластьМакета.Параметры.ФИОРуководителя = ДолжностьРуководителя + Руководители.Руководитель;
	КонецЕсли;  		
	
	Если НЕ Ссылка.Ответственный.ФизЛицо.Пустая() Тогда
		ДанныеОтветственногоЛица = ПроцедурыУправленияПерсоналом.ДанныеФизЛица(Ссылка.Организация, Ссылка.Ответственный.ФизЛицо, Ссылка.Дата);
		ОбластьМакета.Параметры.ФИОИсполнителя = ДанныеОтветственногоЛица.Представление;
		ОбластьМакета.Параметры.ДолжностьИсполнителя = ДанныеОтветственногоЛица.Должность;
	КонецЕсли;		
	
	ТабДокумент.Вывести(ОбластьМакета);
	
	Возврат ТабДокумент;

КонецФункции
