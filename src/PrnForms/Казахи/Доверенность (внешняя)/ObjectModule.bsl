﻿
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
 
	ТабДокумент = ПечатьДоверенности(); 
	//ТабДокумент = Новый ТабличныйДокумент;
	
	Если ТабДокумент <> Неопределено Тогда
		//УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(СсылкаНаОбъект, ""), СсылкаНаОбъект);
	КонецЕсли; 
	
	Возврат ТабДокумент;
	
КонецФункции // Печать

Функция ПечатьДоверенности()
	
	Ссылка = СсылкаНаОбъект;
	
	Запрос = Новый Запрос();
	Запрос.УстановитьПараметр("ТекущийДокумент", Ссылка);
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Доверенность.Номер КАК НомерДокумента,
	|	Доверенность.Дата КАК ДатаДокумента,
	|	Доверенность.СтруктурнаяЕдиница КАК БанковскийСчет,
	|	Доверенность.Организация,
	|	Доверенность.ФизЛицо,
	|	Доверенность.ФизЛицо.Наименование КАК ФамилияИмяОчествоДоверенного,
	|	Доверенность.Контрагент КАК Поставщик,
	|	ПОДСТРОКА(Доверенность.НаПолучениеОт, 1, 250) КАК ПоставщикПредставление,
	|	Доверенность.ДатаДействия КАК СрокДействия,
	|	ПОДСТРОКА(Доверенность.ПоДокументу, 1, 250) КАК РеквизитыДокументаНаПолучение
	|ИЗ
	|	Документ.Доверенность КАК Доверенность
	|ГДЕ
	|	Доверенность.Ссылка = &ТекущийДокумент";
	Шапка = Запрос.Выполнить().Выбрать();
	Шапка.Следующий();
	
	//запрос по товарам
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", Ссылка);
	Запрос.Текст = "ВЫБРАТЬ
	               |	Доверенность.НомерСтроки КАК Номер,
	               |	Доверенность.НаименованиеТовара КАК Ценнности,
	               |	Доверенность.НаименованиеТовара КАК ЦеннностиПредставление,
	               |	Доверенность.ЕдиницаПоКлассификатору КАК ЕдиницаИзмерения,
	               |	Доверенность.ЕдиницаПоКлассификатору.Представление КАК ЕдиницаИзмеренияПредставление,
	               |	Доверенность.Количество
	               |ИЗ
	               |	Документ.Доверенность.Товары КАК Доверенность
	               |ГДЕ
	               |	Доверенность.Ссылка = &ТекущийДокумент
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	Номер";
    
	ВыборкаСтрокТовары = Запрос.Выполнить().Выбрать();

	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_Доверенность_Д1";

	Макет = ПолучитьМакет("Д1");

	ДанныеОФизЛице = ПроцедурыУправленияПерсоналом.ДанныеФизЛица(Шапка.Организация, Шапка.ФизЛицо, Шапка.ДатаДокумента);
	
	ФамилияИмяОчествоДоверенного = ""+ДанныеОФизЛице.Фамилия +" "+ ДанныеОФизЛице.Имя +" "+ ДанныеОФизЛице.Отчество;
	Должность                    = СокрЛП(ДанныеОФизЛице.Должность);
    СтруктураФИО = Новый Структура();
	СтруктураФИО.Вставить("Фамилия", ДанныеОФизЛице.Фамилия);
	СтруктураФИО.Вставить("Имя", ДанныеОФизЛице.Имя);
	СтруктураФИО.Вставить("Отчество", ДанныеОФизЛице.Отчество);
	
	Руководители = ОбщегоНазначения.ОтветственныеЛицаОрганизаций(Шапка.Организация, Шапка.ДатаДокумента);
	Руководитель = Руководители.Руководитель;
	Бухгалтер    = Руководители.ГлавныйБухгалтер;
	
	СведенияОбОрганизации = ОбщегоНазначения.СведенияОЮрФизЛице(Шапка.Организация, Шапка.ДатаДокумента, , Шапка.БанковскийСчет);
	ПредставлениеОрганизации = ОбщегоНазначения.ОписаниеОрганизации(СведенияОбОрганизации, "ПолноеНаименование,");
	
	ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ОбластьМакета.Параметры.ПредставлениеОрганизации = ПредставлениеОрганизации;
	ОбластьМакета.Параметры.НомерДокумента           = СокрЛП(Ссылка.Номер);//ОбщегоНазначения.ПолучитьНомерНаПечать(Ссылка, глСписокПрефиксовУзлов);
	СрокДействия                                     = Формат(Шапка.СрокДействия, "Л=ru_RU; ДЛФ=DD");
	ОбластьМакета.Параметры.ДатаВыдачи               = Формат(Шапка.ДатаДокумента,"Л=ru; ДЛФ=DD");
	РеквизитыСчета									 = ОбщегоНазначения.ОписаниеОрганизации(СведенияОбОрганизации, "НомерСчета,Банк,БИК,");
	Позиция 										 = Найти(РеквизитыСчета, " в банке ");
	НаименованиеБанка_                               = Сред(РеквизитыСчета, Позиция + 9, СтрДлина(РеквизитыСчета));
	ОбластьМакета.Параметры.НаименованиеБанка        = НаименованиеБанка_;
	НомерСчета_                                      = ОбщегоНазначения.ОписаниеОрганизации(СведенияОбОрганизации, "НомерСчета,");
	ОбластьМакета.Параметры.НомерСчета               = НомерСчета_;
	
	ОбластьМакета.Параметры.ОрганизацияРНН_БИН		 	  = ОбщегоНазначения.ОписаниеОрганизации(СведенияОбОрганизации, "БИН_ИИН,", Ложь, Шапка.ДатаДокумента, "ru");
	ОбластьМакета.Параметры.РеквизитыПотребителя     	  = ОбщегоНазначения.ОписаниеОрганизации(СведенияОбОрганизации, "ПолноеНаименование,БИН_ИИН,ЮридическийАдрес,", , Шапка.ДатаДокумента, "ru");
	ОбластьМакета.Параметры.РеквизитыПлательщика     	  = ОбщегоНазначения.ОписаниеОрганизации(СведенияОбОрганизации, "ПолноеНаименование,БИН_ИИН,ЮридическийАдрес,", , Шапка.ДатаДокумента, "ru");
	ОбластьМакета.Параметры.ПаспортСерия             	  = ДанныеОФизЛице.ДокументСерия;
	ОбластьМакета.Параметры.ПаспортНомер             	  = ДанныеОФизЛице.ДокументНомер;
	ОбластьМакета.Параметры.ПаспортВыдан             	  = ДанныеОФизЛице.ДокументКемВыдан;
	ОбластьМакета.Параметры.ПаспортДатаВыдачи             = Формат(ДанныеОФизЛице.ДокументДатаВыдачи, "Л=ru; ДФ=dd.MM.yyyy");
	ОбластьМакета.Параметры.РеквизитыДокументаНаПолучение = СокрЛП(Шапка.РеквизитыДокументаНаПолучение);
	ОбластьМакета.Параметры.ПоставщикПредставление   	  = СокрЛП(Шапка.ПоставщикПредставление);
	
	Если  Не Ссылка.ФИзЛицо.Пустая() Тогда
		ОбластьМакета.Параметры.ФамилияИмяОчествоДоверенного = ОбщегоНазначения.ПреобразоватьФИОВДательныйПадеж(СтруктураФИО, ДанныеОФизЛице.НеСклонятьФамилию);
		ОбластьМакета.Параметры.ДолжностьДоверенного     = Должность;
	КонецЕсли;
	
	ТабДокумент.Вывести(ОбластьМакета);
	
	ОбластьМакета = Макет.ПолучитьОбласть("ЗаголовокТаблицы");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Строка");

	ИтогоКоличество=0;

	Пока ВыборкаСтрокТовары.Следующий() Цикл
		
		 Количество = ВыборкаСтрокТовары.Количество;

		ОбластьМакета.Параметры.Заполнить(ВыборкаСтрокТовары);
		Если ТипЗнч(ВыборкаСтрокТовары.ЦеннностиПредставление) = Тип("Строка") Тогда
			ЦеннностиПредставление = ВыборкаСтрокТовары.ЦеннностиПредставление;
		Иначе
			ЦеннностиПредставление = ВыборкаСтрокТовары.ЦеннностиПредставление.НаименованиеПолное;
		КонецЕсли;
		
		ОбластьМакета.Параметры.ЦеннностиПредставление = ЦеннностиПредставление;
		
		ОбластьМакета.Параметры.КоличествоПрописью = "";
		
		Если ВыборкаСтрокТовары.Количество <> 0 Тогда
			ОбластьМакета.Параметры.КоличествоПрописью = Строка(ВыборкаСтрокТовары.Количество) + " (" + 
													 СокрЛП(ОбщегоНазначения.КоличествоПрописью(ВыборкаСтрокТовары.Количество)) + ")";
		    										 
		КонецЕсли;											 
		
		ТабДокумент.Вывести(ОбластьМакета);
		
		ИтогоКоличество = ИтогоКоличество + Количество;
        
	КонецЦикла;
	
	ОбластьМакета = Макет.ПолучитьОбласть("ИтогоТаблицы");
	ОбластьМакета.Параметры.ИтогоКоличество = "";
	
	Если ВыборкаСтрокТовары.Количество <> 0 Тогда
		   ОбластьМакета.Параметры.ИтогоКоличество = Строка(ИтогоКоличество) +  " (" + 
													СокрЛП(ОбщегоНазначения.КоличествоПрописью(ИтогоКоличество)) + ")";
	КонецЕсли;
	
	ТабДокумент.Вывести(ОбластьМакета);
	Руководители = ОбщегоНазначения.ОтветственныеЛицаОрганизаций(Шапка.Организация, Шапка.ДатаДокумента);
	Руководитель = Руководители.Руководитель;
	ГлавныйБухгалтер = Руководители.ГлавныйБухгалтер;
	
	ОбластьМакета = Макет.ПолучитьОбласть("Подвал");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	
	Если ЗначениеЗаполнено(Руководитель) Или Руководитель <> Неопределено Тогда
		ОбластьМакета.Параметры.Руководитель     = СокрЛП(Руководитель);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ГлавныйБухгалтер) Или ГлавныйБухгалтер <> Неопределено Тогда
		ОбластьМакета.Параметры.ГлавныйБухгалтер     = СокрЛП(ГлавныйБухгалтер);
	КонецЕсли;
	
	ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;

КонецФункции
