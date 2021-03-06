﻿   // Функция помещает в структуру все данные, отображаемые при печати документа.
// Вызывается из функции ПечатьСчетаЗаказа и из веб-приложения
//
// Параметры:
//  Тип - строка, содержит тип печатаемого документа (счет или заказ)
//
// Возвращаемое значение:
//  Структура
//
Функция ПолучитьПараметрыПечатиСчетаЗаказаСТАРЫЙ(Тип) Экспорт	
	
	ПараметрыПечати = Новый Структура;
	Позиции = Новый Массив;
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", СсылкаНаОбъект);
	Запрос.УстановитьПараметр("ПустойКонтрагент", Справочники.Контрагенты.ПустаяСсылка());
	Запрос.УстановитьПараметр("ПустаяОрганизация", Справочники.Организации.ПустаяСсылка());
	Запрос.Текст ="ВЫБРАТЬ
	              |	СчетНаОплатуПокупателю.Номер,
	              |	СчетНаОплатуПокупателю.Дата,
	              |	СчетНаОплатуПокупателю.ДоговорКонтрагента,
	              |	СчетНаОплатуПокупателю.Организация,
	              |	СчетНаОплатуПокупателю.Контрагент КАК Получатель,
	              |	ВЫБОР
	              |		КОГДА СчетНаОплатуПокупателю.Грузоотправитель = &ПустойКонтрагент
	              |			ТОГДА СчетНаОплатуПокупателю.Организация
	              |		ИНАЧЕ СчетНаОплатуПокупателю.Грузоотправитель
	              |	КОНЕЦ КАК Грузоотправитель,
	              |	ВЫБОР
	              |		КОГДА СчетНаОплатуПокупателю.Грузополучатель = &ПустойКонтрагент
	              |			ТОГДА СчетНаОплатуПокупателю.Контрагент
	              |		ИНАЧЕ СчетНаОплатуПокупателю.Грузополучатель
	              |	КОНЕЦ КАК Грузополучатель,
	              |	СчетНаОплатуПокупателю.Организация КАК Руководители,
	              |	ВЫБОР
	              |		КОГДА СчетНаОплатуПокупателю.Организация.ГоловнаяОрганизация = &ПустаяОрганизация
	              |			ТОГДА СчетНаОплатуПокупателю.Организация
	              |		ИНАЧЕ СчетНаОплатуПокупателю.Организация.ГоловнаяОрганизация
	              |	КОНЕЦ КАК Поставщик,
	              |	СчетНаОплатуПокупателю.СуммаДокумента,
	              |	СчетНаОплатуПокупателю.ВалютаДокумента,
	              |	СчетНаОплатуПокупателю.УчитыватьНДС,
	              |	СчетНаОплатуПокупателю.СуммаВключаетНДС
	              |ИЗ
	              |	Документ.СчетНаОплатуПокупателю КАК СчетНаОплатуПокупателю
	              |ГДЕ
	              |	СчетНаОплатуПокупателю.Ссылка = &ТекущийДокумент";

	Шапка = Запрос.Выполнить().Выбрать();
	Шапка.Следующий();

	СтрокаВыборкиПоляСодержания = ОбработкаТабличныхЧастей.ПолучитьЧастьЗапросаДляВыбораСодержания("СчетНаОплату");
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", СсылкаНаОбъект);
	Запрос.Текст = "ВЫБРАТЬ
	|	ВложенныйЗапрос.Номенклатура,
	|	ВЫРАЗИТЬ (ВложенныйЗапрос.Номенклатура.НаименованиеПолное КАК Строка(1000)) КАК НаименованиеПолное,
	|	ВложенныйЗапрос.Номенклатура.Код                КАК Код,
	|	ВложенныйЗапрос.Номенклатура.Артикул            КАК Артикул,
	|	ВложенныйЗапрос.Количество,
	|	ВложенныйЗапрос.ЕдиницаИзмерения.Представление  КАК ЕдиницаИзмерения,
	|	ВложенныйЗапрос.ПроцентСкидкиНаценки 
	|	+ ВложенныйЗапрос.ПроцентАвтоматическихСкидок   КАК Скидка,
	|	ВложенныйЗапрос.Цена,
	|	ВложенныйЗапрос.Сумма,
	|	ВложенныйЗапрос.СуммаНДС,
	|	ВложенныйЗапрос.Характеристика,
	|	NULL                           КАК Серия,
	|	ВложенныйЗапрос.НомерСтроки    КАК НомерСтроки,
	|	ВложенныйЗапрос.Метка          КАК Метка
	|ИЗ
	|	(ВЫБРАТЬ
	|		СчетНаОплату.Номенклатура               КАК Номенклатура,
	|		СчетНаОплату.ЕдиницаИзмерения           КАК ЕдиницаИзмерения,
	|		СчетНаОплату.ПроцентСкидкиНаценки       КАК ПроцентСкидкиНаценки,
	|		СчетНаОплату.ПроцентАвтоматическихСкидок КАК ПроцентАвтоматическихСкидок,
	|		СчетНаОплату.Цена КАК Цена,
	|		СУММА(СчетНаОплату.Количество)          КАК Количество,
	|		СУММА(СчетНаОплату.Сумма)               КАК Сумма,
	|		СУММА(СчетНаОплату.СуммаНДС)            КАК СуммаНДС,
	|		СчетНаОплату.ХарактеристикаНоменклатуры КАК Характеристика,
	|		МИНИМУМ(СчетНаОплату.НомерСтроки)       КАК НомерСтроки,
	|		0 КАК Метка
	|	ИЗ
	|		Документ.СчетНаОплатуПокупателю.Товары КАК СчетНаОплату
	|	
	|	ГДЕ
	|		СчетНаОплату.Ссылка = &ТекущийДокумент
	|	
	|	СГРУППИРОВАТЬ ПО
	|		СчетНаОплату.Номенклатура,
	|		СчетНаОплату.ЕдиницаИзмерения,
	|		СчетНаОплату.ПроцентСкидкиНаценки,
	|		СчетНаОплату.ПроцентАвтоматическихСкидок,
	|		СчетНаОплату.Цена,
	|		СчетНаОплату.ХарактеристикаНоменклатуры
	|		) КАК ВложенныйЗапрос
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	СчетНаОплату.Номенклатура,
	|	Минимум(" + СтрокаВыборкиПоляСодержания + ") КАК Товар,
	|	СчетНаОплату.Номенклатура.Код     КАК Код,
	|	СчетНаОплату.Номенклатура.Артикул КАК Артикул,
	|	Сумма(СчетНаОплату.Количество),
	|	СчетНаОплату.Номенклатура.ЕдиницаХраненияОстатков,
	|	СчетНаОплату.ПроцентСкидкиНаценки + СчетНаОплату.ПроцентАвтоматическихСкидок,
	|	СчетНаОплату.Цена,
	|	Сумма(СчетНаОплату.Сумма),
	|	Сумма(СчетНаОплату.СуммаНДС),
	|	NULL,
	|	NULL,
	|	Минимум(СчетНаОплату.НомерСтроки),
	|	1
	|ИЗ
	|	Документ.СчетНаОплатуПокупателю.Услуги КАК СчетНаОплату
	|
	|ГДЕ
	|	СчетНаОплату.Ссылка = &ТекущийДокумент
	|	СГРУППИРОВАТЬ ПО
	|		СчетНаОплату.Номенклатура,
	|		СчетНаОплату.ПроцентСкидкиНаценки,
	|		СчетНаОплату.ПроцентАвтоматическихСкидок,
	|		СчетНаОплату.Цена
	|
	|УПОРЯДОЧИТЬ ПО
	|	Метка,
	|	НомерСтроки";

	ЗапросТовары = Запрос.Выполнить().Выгрузить();

	// Выводим шапку накладной

	ПараметрыПечати.Вставить("УчитыватьНДС", Шапка.УчитыватьНДС);
	СведенияОПоставщике = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Поставщик, Шапка.Дата);
	СведенияОПоставщике.Вставить("Организация",Шапка.Поставщик);
	//Сообщить(Шапка.Поставщик);
	//Сообщить(Шапка.Грузоотправитель);
	Если Тип = "Счет" Тогда
		ПараметрыПечати.Вставить("ИНН", СведенияОПоставщике.ИНН);
		ПараметрыПечати.Вставить("КПП", СведенияОПоставщике.КПП);
		ПредставлениеПоставщикаДляПлатПоручения = "";
		СтруктурнаяЕдиница = СсылкаНаОбъект.СтруктурнаяЕдиница;
		Если ЗначениеЗаполнено(СсылкаНаОбъект.Организация.ГоловнаяОрганизация) Тогда
			РасчСч= СведенияОПоставщике.Организация.ОсновнойБанковскийСчет;
			Банк = ?(не ЗначениеЗаполнено(РасчСч.БанкДляРасчетов), РасчСч.Банк, РасчСч.БанкДляРасчетов);
		Иначе
			РасСч = СтруктурнаяЕдиница;
			Банк       = ?(не ЗначениеЗаполнено(СтруктурнаяЕдиница.БанкДляРасчетов), СтруктурнаяЕдиница.Банк, СтруктурнаяЕдиница.БанкДляРасчетов);
		КонецЕсли;
		Если ТипЗнч(РасчСч) = Тип("СправочникСсылка.БанковскиеСчета") Тогда
			БИК        = Банк.Код;
			КоррСчет   = Банк.КоррСчет;
			ГородБанка = Банк.Город;
			НомерСчета = СтруктурнаяЕдиница.НомерСчета;
			
			ПараметрыПечати.Вставить("БИКБанкаПолучателя", БИК);
			ПараметрыПечати.Вставить("БанкПолучателя", Банк);
			ПараметрыПечати.Вставить("БанкПолучателяПредставление", СокрЛП(Банк) + " " + ГородБанка);
			ПараметрыПечати.Вставить("СчетБанкаПолучателя", КоррСчет);
			ПараметрыПечати.Вставить("СчетБанкаПолучателяПредставление", КоррСчет);
			ПараметрыПечати.Вставить("СчетПолучателяПредставление", НомерСчета);
			ПараметрыПечати.Вставить("СчетПолучателя", НомерСчета);
			ПредставлениеПоставщикаДляПлатПоручения = СтруктурнаяЕдиница.ТекстКорреспондента;
		КонецЕсли;
		Если ПустаяСтрока(ПредставлениеПоставщикаДляПлатПоручения) Тогда
			ПредставлениеПоставщикаДляПлатПоручения = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОПоставщике, "ПолноеНаименование,");
		КонецЕсли;
		ПараметрыПечати.Вставить("ПредставлениеПоставщикаДляПлатПоручения", ПредставлениеПоставщикаДляПлатПоручения);
	КонецЕсли; 

	ПараметрыПечати.Вставить("ТекстЗаголовка", ОбщегоНазначения.СформироватьЗаголовокДокумента(Шапка, "Счет на оплату"));
	ПараметрыПечати.Вставить("ТекстПоставщик", ?(Тип = "Счет", "Поставщик:", "Исполнитель:"));
	ПараметрыПечати.Вставить("ПредставлениеПоставщика", ФормированиеПечатныхФорм.ОписаниеОрганизации(УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(СведенияОПоставщике.Организация, Шапка.Дата), "ПолноеНаименование,ИНН,КПП,ЮридическийАдрес,Телефоны,"));
	Если Шапка.Организация = Шапка.Грузоотправитель Тогда
		ПараметрыПечати.Вставить("ПредставлениеГрузоотправителя", ФормированиеПечатныхФорм.ОписаниеОрганизации(УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Организация, Шапка.Дата), "ПолноеНаименование,ИНН,КПП,ЮридическийАдрес,Телефоны,"));
	Иначе
		ПараметрыПечати.Вставить("ПредставлениеГрузоотправителя", ФормированиеПечатныхФорм.ОписаниеОрганизации(УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Грузоотправитель, Шапка.Дата), "ПолноеНаименование,ИНН,КПП,ФактическийАдрес,Телефоны,"));
	КонецЕсли;
	СведенияОПолучателе = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Получатель, Шапка.Дата);
	ПараметрыПечати.Вставить("ТекстПокупатель", ?(Тип = "Счет", "Покупатель:", "Заказчик:"));
	ПараметрыПечати.Вставить("ПредставлениеПолучателя", ФормированиеПечатныхФорм.ОписаниеОрганизации(УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Получатель, Шапка.Дата), "ПолноеНаименование,ИНН,КПП,ЮридическийАдрес,Телефоны,"));
	ПараметрыПечати.Вставить("ПредставлениеГрузополучателя", ФормированиеПечатныхФорм.ОписаниеОрганизации(УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Грузополучатель, Шапка.Дата), "ПолноеНаименование,ИНН,КПП,ФактическийАдрес,Телефоны,"));

	ПараметрыПечати.Вставить("ЕстьСкидки", Ложь);
	Для каждого ВыборкаСтрокТовары Из ЗапросТовары Цикл 
		Если ЗначениеЗаполнено(ВыборкаСтрокТовары.Скидка) Тогда
			ПараметрыПечати.ЕстьСкидки = Истина;
			Прервать;
		КонецЕсли; 
	КонецЦикла;

	ДопКолонка = Константы.ДополнительнаяКолонкаПечатныхФормДокументов.Получить();
	ПараметрыПечати.Вставить("ВыводитьКоды", Ложь);
	Если ДопКолонка = Перечисления.ДополнительнаяКолонкаПечатныхФормДокументов.Артикул Тогда
		ПараметрыПечати.ВыводитьКоды = Истина;
		Колонка = "Артикул";
	ИначеЕсли ДопКолонка = Перечисления.ДополнительнаяКолонкаПечатныхФормДокументов.Код Тогда
		ПараметрыПечати.ВыводитьКоды = Истина;
		Колонка = "Код";
	КонецЕсли;
	
	Если ПараметрыПечати.ВыводитьКоды Тогда
		ПараметрыПечати.Вставить("ИмяКолонкиКодов", Колонка);
	КонецЕсли;

	Сумма    = 0;
	СуммаНДС = 0;
	ВсегоСкидок    = 0;
	ВсегоБезСкидок = 0;

	Для каждого ВыборкаСтрокТовары Из ЗапросТовары Цикл 
		
		ПараметрыПозиции = Новый Структура;

		ПараметрыПозиции.Вставить("Номенклатура", ВыборкаСтрокТовары.Номенклатура);
		ПараметрыПозиции.Вставить("НомерСтроки", ЗапросТовары.Индекс(ВыборкаСтрокТовары) + 1);

		Если ПараметрыПечати.ВыводитьКоды Тогда
			Если Колонка = "Артикул" Тогда
				ПараметрыПозиции.Вставить("Артикул", ВыборкаСтрокТовары.Артикул);
			Иначе
				ПараметрыПозиции.Вставить("Артикул", ВыборкаСтрокТовары.Код);
			КонецЕсли;
		КонецЕсли;

		ПараметрыПозиции.Вставить("Количество", ВыборкаСтрокТовары.Количество);
		ПараметрыПозиции.Вставить("ЕдиницаИзмерения", ВыборкаСтрокТовары.ЕдиницаИзмерения);
		ПараметрыПозиции.Вставить("Цена", ВыборкаСтрокТовары.Цена);
		//ПараметрыПозиции.Вставить("Товар", СокрП(ВыборкаСтрокТовары.НаименованиеПолное) 
		//											+ ФормированиеПечатныхФорм.ПредставлениеСерий(ВыборкаСтрокТовары));
		ПараметрыПозиции.Вставить("Товар", СокрЛП(ВыборкаСтрокТовары.НаименованиеПолное));

		Скидка = 0;//Ценообразование.ПолучитьСуммуСкидки(ВыборкаСтрокТовары.Сумма, ВыборкаСтрокТовары.Скидка);

		Если ПараметрыПечати.ЕстьСкидки Тогда
			ПараметрыПозиции.Вставить("Скидка", Скидка);
			ПараметрыПозиции.Вставить("СуммаБезСкидки", ВыборкаСтрокТовары.Сумма + Скидка);
		КонецЕсли;

		ПараметрыПозиции.Вставить("Сумма", ВыборкаСтрокТовары.Сумма); 
		
		Сумма          = Сумма       + ВыборкаСтрокТовары.Сумма;
		СуммаНДС       = СуммаНДС    + ВыборкаСтрокТовары.СуммаНДС;
		ВсегоСкидок    = ВсегоСкидок + Скидка;
		ВсегоБезСкидок = Сумма       + ВсегоСкидок;
		//#Если ВнешнееСоединение Тогда
		//WEBПриложения.ПодготовитьСтруктуруДляВнешнегоСоединения(ПараметрыПозиции);
		//#КонецЕсли

		Позиции.Добавить(ПараметрыПозиции);

	КонецЦикла;
	
	ПараметрыПечати.Вставить("Позиции", Позиции);

	// Вывести Итого
	Если ПараметрыПечати.ЕстьСкидки Тогда
		ПараметрыПечати.Вставить("ВсегоСкидок", ВсегоСкидок);
		ПараметрыПечати.Вставить("ВсегоБезСкидок", ВсегоБезСкидок);
	КонецЕсли;
	ПараметрыПечати.Вставить("Всего", ОбщегоНазначения.ФорматСумм(Сумма));

	// Вывести ИтогоНДС
	Если ПараметрыПечати.УчитыватьНДС Тогда
		ПараметрыПечати.Вставить("НДС", ?(Шапка.СуммаВключаетНДС, "В том числе НДС:", "Сумма НДС:"));
		ПараметрыПечати.Вставить("ВсегоНДС", ОбщегоНазначения.ФорматСумм(ЗапросТовары.Итог("СуммаНДС")));
		ПараметрыПечати.Вставить("ВсегоКОплате", ОбщегоНазначения.ФорматСумм(Сумма + ?(Шапка.СуммаВключаетНДС, 0, СуммаНДС)));
	КонецЕсли;

	// Вывести Сумму прописью
	СуммаКПрописи = Сумма + ?(Шапка.СуммаВключаетНДС, 0, СуммаНДС);
	ПараметрыПечати.Вставить("ИтоговаяСтрока", "Всего наименований " + ЗапросТовары.Количество()
	+ ", на сумму " + ОбщегоНазначения.ФорматСумм(СуммаКПрописи, Шапка.ВалютаДокумента));
	ПараметрыПечати.Вставить("СуммаПрописью", ОбщегоНазначения.СформироватьСуммуПрописью(СуммаКПрописи, Шапка.ВалютаДокумента));

	// Вывести подписи
	Если Тип = "Счет" Тогда
		Руководители = РегламентированнаяОтчетность.ОтветственныеЛицаОрганизаций(Шапка.Руководители, Шапка.Дата,);
		Руководитель = Руководители.Руководитель;
		ДолжностьРуководителя = Руководители.РуководительДолжность;
		Бухгалтер    = Руководители.ГлавныйБухгалтер;
		
		ПараметрыПечати.Вставить("ФИОРуководителя", 		Руководитель);
		ПараметрыПечати.Вставить("ДолжностьРуководителя", 	ДолжностьРуководителя);
		ПараметрыПечати.Вставить("ФИОБухгалтера", 			Бухгалтер);
		
		Ответственный = СсылкаНаОбъект.Ответственный;
		Если НЕ ЗначениеЗаполнено(СсылкаНаОбъект.Ответственный.ФизЛицо) Тогда
			ФИООтветственный = СокрЛП(СсылкаНаОбъект.Ответственный);  
		Иначе
			ФамилияИмяОтчествоФизЛица      	 = ФормированиеПечатныхФорм.ФамилияИмяОтчество(Ответственный.ФизЛицо, Шапка.Дата);
			ФамилияИмяОтчествоОтветственного = ФамилияИмяОтчествоФизЛица.Фамилия + " " + ФамилияИмяОтчествоФизЛица.Имя + " " + ФамилияИмяОтчествоФизЛица.Отчество;
			ФИООтветственный         		 = ОбщегоНазначения.ФамилияИнициалыФизЛица(ФамилияИмяОтчествоОтветственного);
		КонецЕсли;
		ПараметрыПечати.Вставить("ФИООтветственный", ФИООтветственный);

	КонецЕсли; 
	//#Если ВнешнееСоединение Тогда
	//WEBПриложения.ПодготовитьСтруктуруДляВнешнегоСоединения(ПараметрыПечати);
	//#КонецЕсли

	Возврат ПараметрыПечати;

КонецФункции //ПолучитьПараметрыПечатиСчетаЗаказа()

Функция ПолучитьПараметрыПечатиСчетаЗаказа(Тип) Экспорт	

	ПараметрыПечати = Новый Структура;
	Позиции = Новый Массив;
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", ЭтотОбъект.СсылкаНаОбъект);
	Запрос.Текст ="
	|ВЫБРАТЬ
	|	Номер,
	|	Дата,
	|	ДоговорКонтрагента,
	|	Организация,
	|	Контрагент КАК Получатель,
	|	Организация КАК Руководители,
	|	Организация КАК Поставщик,
	|	СуммаДокумента,
	|	ВалютаДокумента,
	|	УчитыватьНДС,
	|	СуммаВключаетНДС,
	|	УчитыватьАкциз,
	|	СуммаВключаетАкциз
	|ИЗ
	|	Документ.СчетНаОплатуПокупателю КАК СчетНаОплатуПокупателю
	|
	|ГДЕ
	|	СчетНаОплатуПокупателю.Ссылка = &ТекущийДокумент";

	Шапка = Запрос.Выполнить().Выбрать();
	Шапка.Следующий();

	СтрокаВыборкиПоляСодержания = ОбработкаТабличныхЧастей.ПолучитьЧастьЗапросаДляВыбораСодержания("СчетНаОплату");

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", ЭтотОбъект.СсылкаНаОбъект);
	Запрос.Текст = "ВЫБРАТЬ
	|	ВложенныйЗапрос.Номенклатура,
	|	ВЫРАЗИТЬ (ВложенныйЗапрос.Номенклатура.НаименованиеПолное КАК Строка(1000)) КАК НаименованиеПолное,
	|	ВложенныйЗапрос.Номенклатура.Код                КАК Код,
	|	ВложенныйЗапрос.Номенклатура.Артикул            КАК Артикул,
	|	ВложенныйЗапрос.Количество,
	|	ВложенныйЗапрос.ЕдиницаИзмерения.Представление  КАК ЕдиницаИзмерения,
	|	ВложенныйЗапрос.ПроцентСкидкиНаценки 
	|	+ ВложенныйЗапрос.ПроцентАвтоматическихСкидок   КАК Скидка,
	|	ВложенныйЗапрос.Цена,
	|	ВложенныйЗапрос.Сумма,
	|	ВложенныйЗапрос.СуммаНДС,
	|	ВложенныйЗапрос.СуммаАкциза,
	|	ВложенныйЗапрос.Характеристика,
	|	NULL                           КАК Серия,
	|	ВложенныйЗапрос.НомерСтроки    КАК НомерСтроки,
	|	ВложенныйЗапрос.Метка          КАК Метка
	|ИЗ
	|	(ВЫБРАТЬ
	|		СчетНаОплату.Номенклатура               КАК Номенклатура,
	|		СчетНаОплату.ЕдиницаИзмерения           КАК ЕдиницаИзмерения,
	|		СчетНаОплату.ПроцентСкидкиНаценки       КАК ПроцентСкидкиНаценки,
	|		СчетНаОплату.ПроцентАвтоматическихСкидок КАК ПроцентАвтоматическихСкидок,
	|		СчетНаОплату.Цена КАК Цена,
	|		СУММА(СчетНаОплату.Количество)          КАК Количество,
	|		СУММА(СчетНаОплату.Сумма)               КАК Сумма,
	|		СУММА(СчетНаОплату.СуммаНДС)            КАК СуммаНДС,
	|		СУММА(СчетНаОплату.СуммаАкциза)         КАК СуммаАкциза,
	|		СчетНаОплату.ХарактеристикаНоменклатуры КАК Характеристика,
	|		МИНИМУМ(СчетНаОплату.НомерСтроки)       КАК НомерСтроки,
	|		0 КАК Метка
	|	ИЗ
	|		Документ.СчетНаОплатуПокупателю.Товары КАК СчетНаОплату
	|	
	|	ГДЕ
	|		СчетНаОплату.Ссылка = &ТекущийДокумент
	|	
	|	СГРУППИРОВАТЬ ПО
	|		СчетНаОплату.Номенклатура,
	|		СчетНаОплату.ЕдиницаИзмерения,
	|		СчетНаОплату.ПроцентСкидкиНаценки,
	|		СчетНаОплату.ПроцентАвтоматическихСкидок,
	|		СчетНаОплату.Цена,
	|		СчетНаОплату.ХарактеристикаНоменклатуры,
	|		СчетНаОплату.НомерСтроки) КАК ВложенныйЗапрос
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	СчетНаОплату.Номенклатура,
	|	" + СтрокаВыборкиПоляСодержания + " КАК Товар,
	|	СчетНаОплату.Номенклатура.Код     КАК Код,
	|	СчетНаОплату.Номенклатура.Артикул КАК Артикул,
	|	СчетНаОплату.Количество,
	|	СчетНаОплату.Номенклатура.ЕдиницаХраненияОстатков,
	|	СчетНаОплату.ПроцентСкидкиНаценки
	|	+ СчетНаОплату.ПроцентАвтоматическихСкидок КАК Скидка,
	|	СчетНаОплату.Цена,
	|	СчетНаОплату.Сумма,
	|	СчетНаОплату.СуммаНДС,
	|	0,
	|	NULL,
	|	NULL,
	|	СчетНаОплату.НомерСтроки,
	|	1
	|ИЗ
	|	Документ.СчетНаОплатуПокупателю.Услуги КАК СчетНаОплату
	|
	|ГДЕ
	|	СчетНаОплату.Ссылка = &ТекущийДокумент
	
	|УПОРЯДОЧИТЬ ПО
	|	Метка,
	|	НомерСтроки";

	ЗапросТовары = Запрос.Выполнить().Выгрузить();

	СтруктурнаяЕдиница = СсылкаНаОбъект.СтруктурнаяЕдиница;
	
	// Выводим шапку накладной
	ПараметрыПечати.Вставить("УчитыватьНДС", Шапка.УчитыватьНДС);
	СведенияОПоставщике = ОбщегоНазначения.СведенияОЮрФизЛице(Шапка.Поставщик, Шапка.Дата);
	Если Тип = "Счет" Тогда
		ТекстРНН_БИН = "";
		ПараметрыПечати.Вставить("ОрганизацияРНН_БИН",ОбщегоНазначения.ПолучитьРегистрационныйНомерОрганизацииКонтрагентаВПечатнуюФорму(СведенияОПоставщике, Шапка.Дата, Ложь, ТекстРНН_БИН));
		ПараметрыПечати.Вставить("ТекстРНН_БИН",ТекстРНН_БИН);
		ПредставлениеПоставщикаДляПлатПоручения = "";
		Если ТипЗнч(СтруктурнаяЕдиница) = Тип("СправочникСсылка.БанковскиеСчета") Тогда
			Банк       = ?(Не ЗначениеЗаполнено(СтруктурнаяЕдиница.БанкДляРасчетов), СтруктурнаяЕдиница.Банк, СтруктурнаяЕдиница.БанкДляРасчетов);
			БИК        = Банк.БИК;
			КоррСчет   = СокрЛП(Банк.КоррСчет);
			ГородБанка = Банк.Город;
			НомерСчета = СтруктурнаяЕдиница.НомерСчета;
			
			ПараметрыПечати.Вставить("БИКБанкаПолучателя", БИК);
			ПараметрыПечати.Вставить("БанкПолучателя", Банк);
			ПараметрыПечати.Вставить("БанкПолучателяПредставление", СокрЛП(Банк) + " " + ГородБанка);
			ПараметрыПечати.Вставить("СчетБанкаПолучателя", КоррСчет);
			ПараметрыПечати.Вставить("СчетБанкаПолучателяПредставление", КоррСчет);
			ПараметрыПечати.Вставить("СчетПолучателяПредставление", НомерСчета);
			ПараметрыПечати.Вставить("СчетПолучателя", НомерСчета);
			ПараметрыПечати.Вставить("КодНазначенияПлатежа", СсылкаНаОбъект.КодНазначенияПлатежа);
			ПредставлениеПоставщикаДляПлатПоручения = СтруктурнаяЕдиница.ТекстКорреспондента;
		КонецЕсли;
		Если ПустаяСтрока(ПредставлениеПоставщикаДляПлатПоручения) Тогда
			ПредставлениеПоставщикаДляПлатПоручения = ОбщегоНазначения.ОписаниеОрганизации(СведенияОПоставщике, "ПолноеНаименование,");
		КонецЕсли;
		ПараметрыПечати.Вставить("ПредставлениеПоставщикаДляПлатПоручения", ПредставлениеПоставщикаДляПлатПоручения);
	КонецЕсли; 

	ПараметрыПечати.Вставить("ТекстЗаголовка", РаботаСДиалогами.СформироватьЗаголовокДокумента(ЭтотОбъект, "Счет на оплату", глСписокПрефиксовУзлов));
	ПараметрыПечати.Вставить("ТекстПоставщик", ?(Тип = "Счет", "Поставщик:", "Исполнитель:"));
	
	//получим сведения поставщика
	СведенияПоставщика = ОбщегоНазначения.СведенияОЮрФизЛице(Шапка.Организация, Шапка.Дата);
	ПараметрыПечати.Вставить("ПредставлениеПоставщикаЗаголовок", СокрЛП(ОбщегоНазначения.ОписаниеОрганизации(СведенияПоставщика, "ПолноеНаименование,ЮридическийАдрес,Телефоны,", , Шапка.Дата)));
	ПараметрыПечати.Вставить("ПредставлениеПоставщика", СокрЛП(ОбщегоНазначения.ОписаниеОрганизации(СведенияПоставщика, "ИдентификационныйНомер,ПолноеНаименование,ЮридическийАдрес,Телефоны,", , Шапка.Дата)));
	ПараметрыПечати.Вставить("ПоставщикКбе", СокрЛП(СведенияПоставщика.Кбе));
	
	СведенияОПолучателе = ОбщегоНазначения.СведенияОЮрФизЛице(Шапка.Получатель, Шапка.Дата);
	ПараметрыПечати.Вставить("ТекстПокупатель", ?(Тип = "Счет", "Покупатель:", "Заказчик:"));
	ПараметрыПечати.Вставить("ПредставлениеПолучателя", СокрЛП(ОбщегоНазначения.ОписаниеОрганизации(ОбщегоНазначения.СведенияОЮрФизЛице(Шапка.Получатель, Шапка.Дата), "ИдентификационныйНомер,ПолноеНаименование,ЮридическийАдрес,Телефоны,",,Шапка.Дата)));
	ПараметрыПечати.Вставить("ДоговорКонтрагента", Шапка.ДоговорКонтрагента);
	
	ПараметрыПечати.Вставить("ЕстьСкидки", Ложь);
	Для каждого ВыборкаСтрокТовары Из ЗапросТовары Цикл 
		Если ЗначениеЗаполнено(ВыборкаСтрокТовары.Скидка) Тогда
			ПараметрыПечати.ЕстьСкидки = Истина;
			Прервать;
		КонецЕсли; 
	КонецЦикла;
	
	ДопКолонка = Константы.ДополнительнаяКолонкаПечатныхФормДокументов.Получить();
	ПараметрыПечати.Вставить("ВыводитьКоды", Ложь);
	Если ДопКолонка = Перечисления.ДополнительнаяКолонкаПечатныхФормДокументов.Артикул Тогда
		ПараметрыПечати.ВыводитьКоды = Истина;
		Колонка = "Артикул";
	ИначеЕсли ДопКолонка = Перечисления.ДополнительнаяКолонкаПечатныхФормДокументов.Код Тогда
		ПараметрыПечати.ВыводитьКоды = Истина;
		Колонка = "Код";
	КонецЕсли;
	
	Если ПараметрыПечати.ВыводитьКоды Тогда
		ПараметрыПечати.Вставить("ИмяКолонкиКодов", Колонка);
	КонецЕсли;

	Сумма    = 0;
	СуммаНДС = 0;
	СуммаАкциза = 0;
	ВсегоСкидок    = 0;
	ВсегоБезСкидок = 0;

	Для каждого ВыборкаСтрокТовары Из ЗапросТовары Цикл 
		
		ПараметрыПозиции = Новый Структура;

		ПараметрыПозиции.Вставить("Номенклатура", ВыборкаСтрокТовары.Номенклатура);
		ПараметрыПозиции.Вставить("НомерСтроки", ЗапросТовары.Индекс(ВыборкаСтрокТовары) + 1);

		Если ПараметрыПечати.ВыводитьКоды Тогда
			Если Колонка = "Артикул" Тогда
				ПараметрыПозиции.Вставить("Артикул", ВыборкаСтрокТовары.Артикул);
			Иначе
				ПараметрыПозиции.Вставить("Артикул", ВыборкаСтрокТовары.Код);
			КонецЕсли;
		КонецЕсли;

		ПараметрыПозиции.Вставить("Количество", ВыборкаСтрокТовары.Количество);
		ПараметрыПозиции.Вставить("ЕдиницаИзмерения", ВыборкаСтрокТовары.ЕдиницаИзмерения);
		ПараметрыПозиции.Вставить("Цена", ВыборкаСтрокТовары.Цена);
		ПараметрыПозиции.Вставить("Товар", СокрП(ВыборкаСтрокТовары.НаименованиеПолное) 
		+ ФормированиеПечатныхФорм.ПредставлениеСерий(ВыборкаСтрокТовары));
		
		Если Не ЗначениеЗаполнено(ВыборкаСтрокТовары.Скидка) Тогда
			Скидка = 0;
		Иначе
			Если   ВыборкаСтрокТовары.Скидка = 100 Тогда
				Скидка = Окр(ВыборкаСтрокТовары.Количество  * ВыборкаСтрокТовары.Цена,2,1);
			Иначе
				Скидка = ВыборкаСтрокТовары.Сумма  / (100 - ВыборкаСтрокТовары.Скидка) * ВыборкаСтрокТовары.Скидка;
			КонецЕсли;
		КонецЕсли;
		
		Если ПараметрыПечати.ЕстьСкидки Тогда
			ПараметрыПозиции.Вставить("Скидка", Скидка);
			ПараметрыПозиции.Вставить("СуммаБезСкидки", ВыборкаСтрокТовары.Сумма + Скидка);
		КонецЕсли;
		
		ПараметрыПозиции.Вставить("Сумма", ВыборкаСтрокТовары.Сумма); 
		
		Сумма          = Сумма       + ВыборкаСтрокТовары.Сумма + ?((Шапка.УчитыватьАкциз И НЕ Шапка.СуммаВключаетАкциз), ВыборкаСтрокТовары.СуммаАкциза, 0);
		СуммаНДС       = СуммаНДС    + ВыборкаСтрокТовары.СуммаНДС;
		СуммаАкциза    = СуммаАкциза + ВыборкаСтрокТовары.СуммаАкциза;
		ВсегоСкидок    = ВсегоСкидок + Скидка;
		ВсегоБезСкидок = Сумма       + ВсегоСкидок + ?((Шапка.УчитыватьАкциз И НЕ Шапка.СуммаВключаетАкциз), ВыборкаСтрокТовары.СуммаАкциза, 0);
		
		Позиции.Добавить(ПараметрыПозиции);

	КонецЦикла;
	
	ПараметрыПечати.Вставить("Позиции", Позиции);

	// Вывести Итого
	Если ПараметрыПечати.ЕстьСкидки Тогда
		ПараметрыПечати.Вставить("ВсегоСкидок", ВсегоСкидок);
		ПараметрыПечати.Вставить("ВсегоБезСкидок", ВсегоБезСкидок);
	КонецЕсли;
	ПараметрыПечати.Вставить("Всего", ОбщегоНазначения.ФорматСумм(Сумма));

	// Вывести ИтогоНДС
	Если ПараметрыПечати.УчитыватьНДС Тогда
		ПараметрыПечати.Вставить("НДС", ?(Шапка.СуммаВключаетНДС, "В том числе НДС:", "Сумма НДС:"));
		ПараметрыПечати.Вставить("ВсегоНДС", ОбщегоНазначения.ФорматСумм(ЗапросТовары.Итог("СуммаНДС")));
	КонецЕсли;

	// Вывести Сумму прописью
	СуммаКПрописи = Сумма + ?(Шапка.СуммаВключаетНДС, 0, СуммаНДС);
	ПараметрыПечати.Вставить("ИтоговаяСтрока", "Всего наименований " + ЗапросТовары.Количество()
	+ ", на сумму " + ОбщегоНазначения.ФорматСумм(СуммаКПрописи, Шапка.ВалютаДокумента));
	ПараметрыПечати.Вставить("СуммаПрописью", ОбщегоНазначения.СформироватьСуммуПрописью(СуммаКПрописи, Шапка.ВалютаДокумента));

	Ответственный = СсылкаНаОбъект.Ответственный;
	
	// Вывести подписи
	Если Тип = "Счет" Тогда
		Руководители = ОбщегоНазначения.ОтветственныеЛицаОрганизаций(Шапка.Руководители, Шапка.Дата,);
		Руководитель = Руководители.Руководитель;
		Бухгалтер    = Руководители.ГлавныйБухгалтер;

		ПараметрыПечати.Вставить("ФИОРуководителя", "/" + Руководитель  + "/");
		ПараметрыПечати.Вставить("ФИОБухгалтера", "/" + Бухгалтер     + "/");
		ПараметрыПечати.Вставить("ФИОИсполнителя", "/" + Ответственный + "/");

	КонецЕсли; 
	
	Возврат ПараметрыПечати;

КонецФункции //ПолучитьПараметрыПечатиСчетаЗаказа()


// Функция создает табличный документ для печати счета и заказа, 
// помещая в него готовые данные, переданные в виде структуры.
//
// Параметры:
//  Тип             - строка, содержит тип печатаемого документа (счет или заказ);
//  ПараметрыПечати - структура с данными для печати.
//
// Возвращаемое значение:
//  Табличный документ - сформированная печатная форма
//
Функция СоздатьТабличныйДокументПечатиСчетаЗаказа(Тип, ПараметрыПечати)
		
	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ЗаказПокупателя_СчетЗаказ";

	Макет = ПолучитьМакет("Счет");
	//Макет = ПолучитьОбщийМакет("Счет123");

	// Выводим шапку накладной

	Если Тип = "Счет" Тогда
		ОбластьМакета       = Макет.ПолучитьОбласть("ЗаголовокСчета");
		ОбластьМакета.Параметры.Заполнить(ПараметрыПечати);
		ТабДокумент.Вывести(ОбластьМакета);
	КонецЕсли; 
	Если ЗначениеЗаполнено(СсылкаНаОбъект.Организация.ГоловнаяОрганизация) Тогда
		//Сообщить("Ля-ля");//ПараметрыПечати
	КонецЕсли;
	ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");
	ОбластьМакета.Параметры.Заполнить(ПараметрыПечати);
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Поставщик");
	ОбластьМакета.Параметры.Заполнить(ПараметрыПечати);
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Покупатель");
	ОбластьМакета.Параметры.Заполнить(ПараметрыПечати);
	ТабДокумент.Вывести(ОбластьМакета);
	
	ОбластьНомера = Макет.ПолучитьОбласть("ШапкаТаблицы|НомерСтроки");
	ОбластьКодов  = Макет.ПолучитьОбласть("ШапкаТаблицы|КолонкаКодов");
	ОбластьДанных = Макет.ПолучитьОбласть("ШапкаТаблицы|Данные");
	ОбластьСкидок = Макет.ПолучитьОбласть("ШапкаТаблицы|Скидка");
	ОбластьСуммы  = Макет.ПолучитьОбласть("ШапкаТаблицы|Сумма");

	ОбластьТовар = Макет.ПолучитьОбласть("ШапкаТаблицы|Товар");
	Если Не ПараметрыПечати.ВыводитьКоды И ПараметрыПечати.ЕстьСкидки Тогда
		ОбластьТовар = Макет.ПолучитьОбласть("ШапкаТаблицы|ТоварБезКодов");
	ИначеЕсли НЕ ПараметрыПечати.ЕстьСкидки И ПараметрыПечати.ВыводитьКоды Тогда
		ОбластьТовар = Макет.ПолучитьОбласть("ШапкаТаблицы|ТоварБезСкидок");
	ИначеЕсли НЕ ПараметрыПечати.ЕстьСкидки И НЕ ПараметрыПечати.ВыводитьКоды Тогда
		ОбластьТовар = Макет.ПолучитьОбласть("ШапкаТаблицы|ТоварБезКодовИСкидок");
	КонецЕсли;

	ТабДокумент.Вывести(ОбластьНомера);
	Если ПараметрыПечати.ВыводитьКоды Тогда
		ОбластьКодов.Параметры.ИмяКолонкиКодов = ПараметрыПечати.ИмяКолонкиКодов;
		ТабДокумент.Присоединить(ОбластьКодов);
	КонецЕсли;
	ОбластьТовар.Параметры.Товар = "Товары (работы, услуги)";
	ТабДокумент.Присоединить(ОбластьТовар);
	ТабДокумент.Присоединить(ОбластьДанных);
	Если ПараметрыПечати.ЕстьСкидки Тогда
		ТабДокумент.Присоединить(ОбластьСкидок);
	КонецЕсли;
	ТабДокумент.Присоединить(ОбластьСуммы);

	ОбластьНомера = Макет.ПолучитьОбласть("Строка|НомерСтроки");
	ОбластьКодов  = Макет.ПолучитьОбласть("Строка|КолонкаКодов");
	ОбластьДанных = Макет.ПолучитьОбласть("Строка|Данные");
	ОбластьСкидок = Макет.ПолучитьОбласть("Строка|Скидка");
	ОбластьСуммы  = Макет.ПолучитьОбласть("Строка|Сумма");

	ОбластьТовар = Макет.ПолучитьОбласть("Строка|Товар");
	Если Не ПараметрыПечати.ВыводитьКоды И ПараметрыПечати.ЕстьСкидки Тогда
		ОбластьТовар = Макет.ПолучитьОбласть("Строка|ТоварБезКодов");
	ИначеЕсли НЕ ПараметрыПечати.ЕстьСкидки И ПараметрыПечати.ВыводитьКоды Тогда
		ОбластьТовар = Макет.ПолучитьОбласть("Строка|ТоварБезСкидок");
	ИначеЕсли НЕ ПараметрыПечати.ЕстьСкидки И НЕ ПараметрыПечати.ВыводитьКоды Тогда
		ОбластьТовар = Макет.ПолучитьОбласть("Строка|ТоварБезКодовИСкидок");
	КонецЕсли;

	Для каждого ПараметрыПозиции Из ПараметрыПечати.Позиции Цикл 

		Если не ЗначениеЗаполнено(ПараметрыПозиции.Номенклатура) Тогда
			Сообщить("В одной из строк не заполнено значение номенклатуры - строка при печати пропущена.", СтатусСообщения.Важное);
			Продолжить;
		КонецЕсли;

		ОбластьНомера.Параметры.Заполнить(ПараметрыПозиции);
		ТабДокумент.Вывести(ОбластьНомера);

		Если ПараметрыПечати.ВыводитьКоды Тогда
			ОбластьКодов.Параметры.Заполнить(ПараметрыПозиции);
			ТабДокумент.Присоединить(ОбластьКодов);
		КонецЕсли;

		ОбластьТовар.Параметры.Заполнить(ПараметрыПозиции);
		ТабДокумент.Присоединить(ОбластьТовар);
		ОбластьДанных.Параметры.Заполнить(ПараметрыПозиции);
		ТабДокумент.Присоединить(ОбластьДанных);

		Если ПараметрыПечати.ЕстьСкидки Тогда
			ОбластьСкидок.Параметры.Заполнить(ПараметрыПозиции);
			ТабДокумент.Присоединить(ОбластьСкидок);
		КонецЕсли;

		ОбластьСуммы.Параметры.Заполнить(ПараметрыПозиции);
		ТабДокумент.Присоединить(ОбластьСуммы);
		
	КонецЦикла;

	// Вывести Итого
	ОбластьНомера = Макет.ПолучитьОбласть("Итого|НомерСтроки");
	ОбластьКодов  = Макет.ПолучитьОбласть("Итого|КолонкаКодов");
	ОбластьДанных = Макет.ПолучитьОбласть("Итого|Данные");
	ОбластьСкидок = Макет.ПолучитьОбласть("Итого|Скидка");
	ОбластьСуммы  = Макет.ПолучитьОбласть("Итого|Сумма");

	ОбластьТовар = Макет.ПолучитьОбласть("Итого|Товар");
	Если Не ПараметрыПечати.ВыводитьКоды И ПараметрыПечати.ЕстьСкидки Тогда
		ОбластьТовар = Макет.ПолучитьОбласть("Итого|ТоварБезКодов");
	ИначеЕсли НЕ ПараметрыПечати.ЕстьСкидки И ПараметрыПечати.ВыводитьКоды Тогда
		ОбластьТовар = Макет.ПолучитьОбласть("Итого|ТоварБезСкидок");
	ИначеЕсли НЕ ПараметрыПечати.ЕстьСкидки И НЕ ПараметрыПечати.ВыводитьКоды Тогда
		ОбластьТовар = Макет.ПолучитьОбласть("Итого|ТоварБезКодовИСкидок");
	КонецЕсли;

	ТабДокумент.Вывести(ОбластьНомера);
	Если ПараметрыПечати.ВыводитьКоды Тогда
		ТабДокумент.Присоединить(ОбластьКодов);
	КонецЕсли;
	ТабДокумент.Присоединить(ОбластьТовар);
	ТабДокумент.Присоединить(ОбластьДанных);
	Если ПараметрыПечати.ЕстьСкидки Тогда
		ОбластьСкидок.Параметры.Заполнить(ПараметрыПечати);
		ТабДокумент.Присоединить(ОбластьСкидок);
	КонецЕсли;
	ОбластьСуммы.Параметры.Заполнить(ПараметрыПечати);
	ТабДокумент.Присоединить(ОбластьСуммы);

	// Вывести ИтогоНДС
	Если ПараметрыПечати.УчитыватьНДС Тогда
		ОбластьНомера = Макет.ПолучитьОбласть("ИтогоНДС|НомерСтроки");
		ОбластьКодов  = Макет.ПолучитьОбласть("ИтогоНДС|КолонкаКодов");
		ОбластьДанных = Макет.ПолучитьОбласть("ИтогоНДС|Данные");
		ОбластьСкидок = Макет.ПолучитьОбласть("ИтогоНДС|Скидка");
		ОбластьСуммы  = Макет.ПолучитьОбласть("ИтогоНДС|Сумма");

		ОбластьТовар = Макет.ПолучитьОбласть("ИтогоНДС|Товар");
		Если Не ПараметрыПечати.ВыводитьКоды И ПараметрыПечати.ЕстьСкидки Тогда
			ОбластьТовар = Макет.ПолучитьОбласть("ИтогоНДС|ТоварБезКодов");
		ИначеЕсли НЕ ПараметрыПечати.ЕстьСкидки И ПараметрыПечати.ВыводитьКоды Тогда
			ОбластьТовар = Макет.ПолучитьОбласть("ИтогоНДС|ТоварБезСкидок");
		ИначеЕсли НЕ ПараметрыПечати.ЕстьСкидки И НЕ ПараметрыПечати.ВыводитьКоды Тогда
			ОбластьТовар = Макет.ПолучитьОбласть("ИтогоНДС|ТоварБезКодовИСкидок");
		КонецЕсли;

		ТабДокумент.Вывести(ОбластьНомера);
		Если ПараметрыПечати.ВыводитьКоды Тогда
			ТабДокумент.Присоединить(ОбластьКодов);
		КонецЕсли;
		ОбластьТовар.Параметры.Заполнить(ПараметрыПечати);
		ТабДокумент.Присоединить(ОбластьТовар);
		ОбластьДанных.Параметры.Заполнить(ПараметрыПечати);
		ТабДокумент.Присоединить(ОбластьДанных);
		Если ПараметрыПечати.ЕстьСкидки Тогда
			ТабДокумент.Присоединить(ОбластьСкидок);
		КонецЕсли;
		ОбластьСуммы.Параметры.Заполнить(ПараметрыПечати);
		ТабДокумент.Присоединить(ОбластьСуммы);
		
		ОбластьНомера = Макет.ПолучитьОбласть("ВсегоКОплате|НомерСтроки");
		ОбластьКодов  = Макет.ПолучитьОбласть("ВсегоКОплате|КолонкаКодов");
		ОбластьДанных = Макет.ПолучитьОбласть("ВсегоКОплате|Данные");
		ОбластьСкидок = Макет.ПолучитьОбласть("ВсегоКОплате|Скидка");
		ОбластьСуммы  = Макет.ПолучитьОбласть("ВсегоКОплате|Сумма");

		ОбластьТовар = Макет.ПолучитьОбласть("ВсегоКОплате|Товар");
		Если Не ПараметрыПечати.ВыводитьКоды И ПараметрыПечати.ЕстьСкидки Тогда
			ОбластьТовар = Макет.ПолучитьОбласть("ВсегоКОплате|ТоварБезКодов");
		ИначеЕсли НЕ ПараметрыПечати.ЕстьСкидки И ПараметрыПечати.ВыводитьКоды Тогда
			ОбластьТовар = Макет.ПолучитьОбласть("ВсегоКОплате|ТоварБезСкидок");
		ИначеЕсли НЕ ПараметрыПечати.ЕстьСкидки И НЕ ПараметрыПечати.ВыводитьКоды Тогда
			ОбластьТовар = Макет.ПолучитьОбласть("ВсегоКОплате|ТоварБезКодовИСкидок");
		КонецЕсли;

		ТабДокумент.Вывести(ОбластьНомера);
		Если ПараметрыПечати.ВыводитьКоды Тогда
			ТабДокумент.Присоединить(ОбластьКодов);
		КонецЕсли;
		ОбластьТовар.Параметры.Заполнить(ПараметрыПечати);
		ТабДокумент.Присоединить(ОбластьТовар);
		ОбластьДанных.Параметры.Заполнить(ПараметрыПечати);
		ТабДокумент.Присоединить(ОбластьДанных);
		Если ПараметрыПечати.ЕстьСкидки Тогда
			ТабДокумент.Присоединить(ОбластьСкидок);
		КонецЕсли;
		ОбластьСуммы.Параметры.Заполнить(ПараметрыПечати);
		ТабДокумент.Присоединить(ОбластьСуммы);
		
	КонецЕсли;

	// Вывести Сумму прописью
	ОбластьМакета = Макет.ПолучитьОбласть("СуммаПрописью");
	ОбластьМакета.Параметры.Заполнить(ПараметрыПечати);
	ТабДокумент.Вывести(ОбластьМакета);

	// Вывести подписи
	Если Тип = "Счет" Тогда
		ОбластьМакета = Макет.ПолучитьОбласть("ПодвалСчета");
	Иначе
		ОбластьМакета = Макет.ПолучитьОбласть("ПодвалЗаказа");
	КонецЕсли; 
	
	ОбластьМакета.Параметры.Заполнить(ПараметрыПечати);
	
	ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;

КонецФункции // СоздатьТабличныйДокументПечатиСчетаЗаказа()

// Функция формирует табличный документ с печатной формой заказа или счета,
// разработанного методистами
//
// Возвращаемое значение:
//  Табличный документ - сформированная печатная форма
//
Функция ПечатьСчетаЗаказа(Тип)

	Возврат СоздатьТабличныйДокументПечатиСчетаЗаказа(Тип, ПолучитьПараметрыПечатиСчетаЗаказа(Тип));

КонецФункции

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
 	ИмяМакета="Счет";
 
	ТабДокумент = ПечатьСчетаЗаказа(ИмяМакета); 
	//ТабДокумент = Новый ТабличныйДокумент;
	
	Если ТабДокумент <> Неопределено Тогда
		//УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(СсылкаНаОбъект, ""), СсылкаНаОбъект);
	КонецЕсли; 
	
	Возврат ТабДокумент;
	

	
КонецФункции // Печать

