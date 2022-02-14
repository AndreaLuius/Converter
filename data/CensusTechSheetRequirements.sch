<?xml version="1.0" encoding="UTF-8"?>

<!-- 
    File Schematron per Requisiti e Raccomandazioni Scheda Censimento PELL
    Versione: 1.0
    Ultima modifica: 17-07-2020 (aggiornato rispetto alle Linee Guida - Dicembre 2019; è comunque retrocompatibile) 
    
-->

<schema xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" queryBinding="xslt2"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
  <!-- title>Requisiti per la Scheda Censimento PELL Illuminazione Pubblica</title-->
  <ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <ns prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
  <ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>

  <phase id="PELL">
    <active pattern="XML-CensusTechSheet"/>
  </phase>

  <properties>
    <property id="NoStd"/>
  </properties>

  <pattern abstract="false" id="XML-CensusTechSheet">

    <rule context="/CensusTechSheet">

      <assert
        test="number(PLSystemGeneralData/NumberOfConnectedLightSpots) = sum(//ElectricPanelGeneralData/NumberOfConnectedLightSpots)"
        flag="fatal">[Req 13] - Il numero di punti luce totali
        (PLSystemGeneralData/NumberOfConnectedLightSpots) DEVE essere uguale al numero di punti luce
        afferenti ai singoli quadri elettrici descritti nel documento (somma dei valori degli
        elementi //ElectricPanel/ElectricPanelGeneralData/NumberOfConnectedLightSpots).</assert>

      <assert test="number(PLSystemGeneralData/NumberOfConnectedLightSpots) = count(//LightSpot)"
        flag="fatal">[Req 90] - Il numero di punti luce totali
        (PLSystemGeneralData/NumberOfConnectedLightSpots) DEVE essere uguale al numero di punti luce
        descritti nel documento (numero di blocchi //LightSpot).</assert>

      <assert
        test="(count(//LightSpotDevice/LightSpotDeviceID) = count(distinct-values(//LightSpotDevice/normalize-space(LightSpotDeviceID))))"
        flag="fatal">[Req 87] - L'identificativo dell'apparecchio (LightSpotDeviceID) DEVE essere
        univoco all'interno del documento XML.</assert>

      <assert test="(count(//POD/PODCode) = count(distinct-values(//POD/normalize-space(PODCode))))"
        flag="fatal">[Req 88] - Il codice POD (POD/PODCode) DEVE essere univoco all'interno del
        documento XML.</assert>

      <assert
        test="(count(//ElectricPanel/ElectricPanelID) = count(distinct-values(//ElectricPanel/normalize-space(ElectricPanelID))))"
        flag="fatal">[Req 27] - L'identificativo del quadro (//ElectricPanel/ElectricPanelID) DEVE
        essere univoco all'interno del documento XML.</assert>

      <assert
        test="(count(//HomogeneousArea/HomogeneousAreaID) = count(distinct-values(//HomogeneousArea/normalize-space(HomogeneousAreaID))))"
        flag="fatal">[Req 91] - L'identificativo della zona omogenea (HomogeneousAreaID) DEVE essere
        univoco all'interno del documento XML.</assert>

      <assert
        test="(count(//LightSource/LightSourceID) = count(distinct-values(//LightSource/normalize-space(LightSourceID))))"
        flag="fatal">[Req 93] - L'id sorgente luminosa (LightSourceID) DEVE essere univoco
        all'interno del documento XML.</assert>

    </rule>

    <rule context="/CensusTechSheet/PLSystemGeneralData">

      <assert
        test="(count(City) &lt;= 1) or ((count(City[@ln]) = count(City)) and (count(City/@ln) = count(distinct-values(City/@ln))))"
        flag="fatal">[Req 9] - Se il nome comune (City) occorre più di una volta, ogni occorrenza
        DEVE avere l'attributo @ln valorizzato e i valori delle varie occorrenze di @ln DEVONO
        essere distinti.</assert>

      <assert test="not(Surface) or (Surface[@uom = 'km2'])" flag="warning">[Racc 3] - L'attributo
        XML @uom (unità di misura) dell'elemento Surface DOVREBBE essere presente e valorizzato con
        il valore prefissato "km2".</assert>

      <assert test="number(NumberOfConnectedLightSpots) >= number(NumberOfOwnedLightSpots)"
        flag="fatal">[Req 15] - Il numero di punti luce di proprietà (NumberOfOwnedLightSpots) DEVE
        essere minore o uguale al numero di punti luce totali descritti nel singolo documento XML
        (NumberOfConnectedLightSpots).</assert>

    </rule>

    <rule context="//PODGeneralData">
      <let name="podCode" value="preceding-sibling::PODCode"/>

      <assert
        test="
          ((NumberOfElectricPanelsToBeChanged[@xsi:nil = 'true']) and (NumberOfElectricPanelsToBeReconditioned[@xsi:nil = 'true'])) or (number(NumberOfElectricPanels) &gt;= (number(NumberOfElectricPanelsToBeChanged) + number(NumberOfElectricPanelsToBeReconditioned))) or
          ((number(NumberOfElectricPanels) &gt;= number(NumberOfElectricPanelsToBeChanged)) and (NumberOfElectricPanelsToBeReconditioned[@xsi:nil = 'true'])) or ((number(NumberOfElectricPanels) &gt;= number(NumberOfElectricPanelsToBeReconditioned)) and (NumberOfElectricPanelsToBeChanged[@xsi:nil = 'true']))"
        flag="fatal">[Req 18] - Se il numero quadri elettrici da sostituire
        (NumberOfElectricPanelsToBeChanged) e/o il numero quadri elettrici da ricondizionare
        (NumberOfElectricPanelsToBeReconditioned) afferenti un POD sono indicati, la loro somma DEVE
        essere minore o uguale al numero di quadri elettrici (NumberOfElectricPanels) del
        POD.</assert>

      <assert test="(NumberOfElectricPanels) = count(//ElectricPanel[PODCode = $podCode])"
        flag="fatal">[Req 19] - Il numero di quadri elettrici afferenti il POD
        (NumberOfElectricPanels) DEVE essere uguale al numero di quadri elettrici (numero di blocchi
        //ElectricPanel) afferenti quello stesso POD descritti nel documento XML.</assert>

      <assert
        test="(NumberOfElectricPanelsToBeChanged[@xsi:nil = 'true']) or ((NumberOfElectricPanelsToBeChanged) = count(//ElectricPanel[PODCode = $podCode]/ElectricPanelGeneralData[PreservationStatus = '04']))"
        flag="warning">[Racc 4] - Se non nullo, il numero quadri elettrici da sostituire
        (NumberOfElectricPanelsToBeChanged) afferenti il POD DOVREBBE essere uguale al numero di
        quadri elettrici collegati a quel POD aventi stato di conservazione = "da sostituire"
        (ElectricPanel/ElectricPanelGeneralData/PreservationStatus = "04").</assert>

      <assert
        test="(NumberOfElectricPanelsToBeReconditioned[@xsi:nil = 'true']) or ((NumberOfElectricPanelsToBeReconditioned) = count(//ElectricPanel[PODCode = $podCode]/ElectricPanelGeneralData[PreservationStatus = '02' or PreservationStatus = '03']))"
        flag="warning">[Racc 5] - Se non nullo, il numero quadri elettrici da ricondizionare
        (NumberOfElectricPanelsToBeReconditioned) DOVREBBE essere uguale al numero di quadri
        elettrici collegati al POD e aventi stato di conservazione = "da mettere a norma" o "da
        manutenere" (numero di blocchi ElectricPanel aventi
        ElectricPanelGeneralData/PreservationStatus = "02" o = "03").</assert>

    </rule>

    <rule context="//PODConsumptionData">

      <assert
        test="not(InstalledPower) or (InstalledPower[@uom = 'kW']) or (InstalledPower[@xsi:nil = 'true'])"
        flag="warning">[Racc 6] - L'attributo XML @uom (unità di misura) dell'elemento
        InstalledPower DOVREBBE essere presente e valorizzato con il valore prefissato
        "kW".</assert>

      <assert
        test="not(PreviousYearAnnualConsumption) or (PreviousYearAnnualConsumption[@uom = 'kWh'])"
        flag="warning">[Racc 7] - L'attributo XML @uom (unità di misura) dell'elemento
        PreviousYearAnnualConsumption DOVREBBE essere presente e valorizzato con il valore
        prefissato "kWh".</assert>

      <assert test="not(ContractuallyCommittedPower) or (ContractuallyCommittedPower[@uom = 'kW'])"
        flag="warning">[Racc 8] - L'attributo XML @uom (unità di misura) dell'elemento
        ContractuallyCommittedPower DOVREBBE essere presente e valorizzato con il valore prefissato
        "kW".</assert>

      <assert
        test="not(CurrentYearAnnualConsumption) or (CurrentYearAnnualConsumption[@uom = 'kWh'])"
        flag="warning">[Racc 9] - L'attributo XML @uom (unità di misura) dell'elemento
        CurrentYearAnnualConsumption DOVREBBE essere presente e valorizzato con il valore prefissato
        "kWh".</assert>

      <assert
        test="not(PreviousYearElectricEnergyAnnualAmount) or (PreviousYearElectricEnergyAnnualAmount[@currency = 'EUR'])"
        flag="warning">[Racc 2] - L'elemento PreviousYearElectricEnergyAnnualAmount corrisponde ad
        un attributo del Data model indicante un importo, DOVREBBE quindi avere l'attributo XML
        @currency (valuta) valorizzato con il valore prefissato "EUR".</assert>

      <assert
        test="not(CurrentYearElectricEnergyAnnualAmount) or (CurrentYearElectricEnergyAnnualAmount[@currency = 'EUR'])"
        flag="warning">[Racc 2] - L'elemento CurrentYearElectricEnergyAnnualAmount corrisponde ad un
        attributo del Data model indicante un importo, DOVREBBE quindi avere l'attributo XML
        @currency (valuta) valorizzato con il valore prefissato "EUR".</assert>
    </rule>

    <rule context="//ElectricPanel">
      <let name="refPodCode" value="PODCode"/>
      
      <assert test="(count(//POD[PODCode = $refPodCode]) > 0)" flag="fatal">[Req 29] - Il codice POD
        indicato nel quadro elettrico (PODCode) DEVE essere uguale al codice di uno dei POD
        (//POD/PODCode) descritti nel documento XML.</assert>

    </rule>

    <rule context="//ElectricPanel/ElectricPanelGeneralData">
      <let name="electricPanID" value="preceding-sibling::ElectricPanelID"/>
      <let name="hAreaList"
        value="distinct-values(//LightSpot[ElectricPanelID = $electricPanID]/HomogeneousAreaID)"/>

      <assert test="not(ElectricPanelInstalledPower) or (ElectricPanelInstalledPower[@uom = 'kW'])"
        flag="warning">[Racc 11] - L'attributo XML @uom (unità di misura) dell'elemento
        ElectricPanelInstalledPower DOVREBBE essere presente e valorizzato con il valore prefissato
        "kW".</assert>

      <assert
        test="number(NumberOfConnectedLightSpots) = (number(NumberOfOwnedLightSpots) + number(NumberOfNotOwnedLightSpots))"
        flag="fatal">[Req 32] - Il numero totale di punti luce (NumberOfConnectedLightSpots) DEVE
        essere uguale alla somma tra il numero di punti luce di proprietà e non di proprietà
        (NumberOfOwnedLightSpots e NumberOfNotOwnedLightSpots) associati allo stesso
        quadro.</assert>

      <assert
        test="(number(NumberOfConnectedLightSpots) = count(//LightSpot[ElectricPanelID = $electricPanID]))"
        flag="fatal">[Req 33] - Il numero totale di punti luce (NumberOfConnectedLightSpots) DEVE
        essere uguale numero di punti luce associati al quadro elettrico presenti nel documento
        (numero di blocchi LightSpot aventi ElectricPanelID uguale all'identificativo del quadro che
        si sta considerando).</assert>

    </rule>

    <rule context="//ElectricPanel/ElectricPanelTechnicalData">

      <assert
        test="(Ipei2013 = '91') or (Ipei2013 = '93') or (Ipei2013 = '94') or (Ipei2018 = '91') or (Ipei2018 = '93') or (Ipei2018 = '94')"
        flag="fatal">[Req 94] - Se è stato valorizzato l'indice IPEI 2013 (Ipei2013), l'indice IPEI
        2018 (Ipei2018) DEVE assumere uno dei valori di indeterminatezza.</assert>

      <assert test="not(NominalVoltage) or (NominalVoltage[@uom = 'V'])" flag="warning">[Racc 12] -
        L'attributo XML @uom (unità di misura) dell'elemento NominalVoltage DOVREBBE essere presente
        e valorizzato con il valore prefissato "V".</assert>

      <assert
        test="(((TransformerFlag = 'false') or (TransformerFlag[@xsi:nil = 'true']) or not(TransformerFlag)) and (not(TransformerPower) or (TransformerPower[@xsi:nil = 'true']))) or ((TransformerFlag = 'true') and (TransformerPower/node()))"
        flag="fatal">[Req 98] - Se è stato dichiarato che è presente un trasformatore di tensione in
        cabina elettrica, la potenza del trasformatore (TransformerPower) DEVE essere
        presente.</assert>

      <assert
        test="not(TransformerPower) or (TransformerPower[@uom = 'kV*A']) or (TransformerPower[@xsi:nil = 'true'])"
        flag="warning">[Racc 14] - L'attributo XML @uom (unità di misura) dell'elemento
        TransformerPower DOVREBBE essere presente e valorizzato con il valore prefissato
        "kV*A".</assert>

    </rule>

    <rule context="//ElectricPanel/ElectricPanelOperatingData">

      <assert
        test="((PowerOnPartializationFlag = 'true') and (number(NumberOfOperatingHours) > number(NumberOfPartialOperatingHours))) or ((PowerOnPartializationFlag = 'false') and (NumberOfPartialOperatingHours[@xsi:nil = 'true']))"
        flag="fatal">[Req 45] - Se è stato indicato che l'accensione è parzializzata
        (PowerOnPartializationFlag = 'true'), la durata di accensione parzializzata
        (NumberOfPartialOperatingHours) DEVE essere indicata e il valore DEVE essere inferiore al
        numero di ore di accensione dell'impianto (NumberOfOperatingHours). Nel caso di accensione
        non parzializzata (PowerOnPartializationFlag = 'false'), l'elemento
        NumberOfPartialOperatingHours DEVE essere valorizzato con il valore di
        indeterminatezza.</assert>

      <assert
        test="not(PowerOnPartializationFlag = 'true') or (LuminousFluxReducingFlag[@xsi:nil = 'true'])"
        flag="fatal">[Req 46] - In caso di accensione parzializzata (PowerOnPartializationFlag =
        'true'), la riduzione del flusso luminoso (LuminousFluxReducingFlag) DEVE avere valore
        nullo.</assert>

      <assert
        test="((LuminousFluxReducingFlag = 'true') and (not(NumberOfReducedFluxOperatingHours[@xsi:nil = 'true'])) and (number(NumberOfOperatingHours) > number(NumberOfReducedFluxOperatingHours))) or (not(LuminousFluxReducingFlag = 'true') and (NumberOfReducedFluxOperatingHours[@xsi:nil = 'true']))"
        flag="fatal">[Req 48] - In caso di attuazione di strategie di riduzione del flusso luminoso
        (LuminousFluxReducingFlag = 'true'), la durata di riduzione del flusso luminoso
        (NumberOfReducedFluxOperatingHours) DEVE essere valorizzata e il valore DEVE essere
        inferiore al numero di ore di accensione dell'impianto (NumberOfOperatingHours); altrimenti
        DEVE assumere il valore nullo.</assert>

      <assert
        test="((LuminousFluxReducingFlag = 'true') and not(ReductionRate[@xsi:nil = 'true'])) or (not(LuminousFluxReducingFlag = 'true') and (ReductionRate[@xsi:nil = 'true']))"
        flag="fatal">[Req 50] - In caso di utilizzo di strategie di riduzione del flusso luminoso
        (LuminousFluxReducingFlag = 'true'), il valore medio di riduzione del flusso luminoso
        (ReductionRate) DEVE essere valorizzato; altrimenti DEVE assumere il valore nullo.</assert>

      <assert
        test="((not(MeterID) or (MeterID[@xsi:nil = 'true'])) and (not(MeterClass) or (MeterClass = '91') or (MeterClass = '93') or (MeterClass = '94'))) or ((MeterID/text()) and (MeterClass) and not((MeterClass = '91') or (MeterClass = '93') or (MeterClass = '94')))"
        flag="fatal">[Req 51] - Se presenti, le informazioni sul meter DEVONO essere complete:
        occorre indicare sia l'identificativo (MeterID) che la classe (MeterClass).</assert>

      <assert
        test="((PowerOnPartializationFlag = 'false') and (PowerReductionRate[@xsi:nil = 'true'])) or ((PowerOnPartializationFlag = 'true') and not(PowerReductionRate[@xsi:nil = 'true']))"
        flag="fatal">[Req 52] - In caso di parzializzazione accensione tutta notte - mezza notte
        (PowerOnPartializationFlag = 'true'), la percentuale di riduzione della potenza
        (PowerReductionRate) DEVE essere fornita; altrimenti DEVE assumere il valore nullo.</assert>

      <assert
        test="((LuminousFluxReducingFlag = 'true') and (not(PowerAverageReductionRate[@xsi:nil = 'true']))) or (not(LuminousFluxReducingFlag = 'true') and (PowerAverageReductionRate[@xsi:nil = 'true']))"
        flag="fatal">[Req 53] - In caso di utilizzo di strategie di riduzione del flusso luminoso,
        la percentuale di riduzione media della potenza (PowerAverageReductionRate) DEVE essere
        fornita, altrimenti DEVE assumere il valore nullo.</assert>

    </rule>

    <rule context="//ElectricPanel/ElectricPanelMaintenance">
      <assert
        test="not(PreviousYearOrdinaryMaintenanceAmount) or (PreviousYearOrdinaryMaintenanceAmount[@currency = 'EUR'])"
        flag="warning">[Racc 2] - L'elemento PreviousYearOrdinaryMaintenanceAmount corrisponde ad un
        attributo del Data model indicante un importo, DOVREBBE quindi avere l'attributo XML
        @currency (valuta) valorizzato con il valore prefissato "EUR".</assert>

      <assert
        test="not(PreviousYearOtherOrdinaryMaintenanceAmount) or (PreviousYearOtherOrdinaryMaintenanceAmount[@currency = 'EUR'])"
        flag="warning">[Racc 2] - L'elemento PreviousYearOtherOrdinaryMaintenanceAmount corrisponde
        ad un attributo del Data model indicante un importo, DOVREBBE quindi avere l'attributo XML
        @currency (valuta) valorizzato con il valore prefissato "EUR".</assert>

      <assert
        test="not(PreviousYearExtraordinaryMaintenanceAmount) or (PreviousYearExtraordinaryMaintenanceAmount[@currency = 'EUR'])"
        flag="warning">[Racc 2] - L'elemento PreviousYearExtraordinaryMaintenanceAmount corrisponde
        ad un attributo del Data model indicante un importo, DOVREBBE quindi avere l'attributo XML
        @currency (valuta) valorizzato con il valore prefissato "EUR".</assert>

      <assert
        test="not(CurrentYearOrdinaryMaintenanceAmount) or (CurrentYearOrdinaryMaintenanceAmount[@currency = 'EUR'])"
        flag="warning">[Racc 2] - L'elemento CurrentYearOrdinaryMaintenanceAmount corrisponde ad un
        attributo del Data model indicante un importo, DOVREBBE quindi avere l'attributo XML
        @currency (valuta) valorizzato con il valore prefissato "EUR".</assert>

      <assert
        test="not(CurrentYearOtherOrdinaryMaintenanceAmount) or (CurrentYearOtherOrdinaryMaintenanceAmount[@currency = 'EUR'])"
        flag="warning">[Racc 2] - L'elemento CurrentYearOtherOrdinaryMaintenanceAmount corrisponde
        ad un attributo del Data model indicante un importo, DOVREBBE quindi avere l'attributo XML
        @currency (valuta) valorizzato con il valore prefissato "EUR".</assert>

      <assert
        test="not(CurrentYearExtraordinaryMaintenanceAmount) or (CurrentYearExtraordinaryMaintenanceAmount[@currency = 'EUR'])"
        flag="warning">[Racc 2] - L'elemento CurrentYearExtraordinaryMaintenanceAmount corrisponde
        ad un attributo del Data model indicante un importo, DOVREBBE quindi avere l'attributo XML
        @currency (valuta) valorizzato con il valore prefissato "EUR".</assert>

    </rule>


    <rule context="//LightSpot">
      <let name="electricPanID" value="ElectricPanelID"/>
      <let name="homogArea" value="HomogeneousAreaID"/>

      <assert test="(//ElectricPanel[ElectricPanelID = $electricPanID])" flag="fatal">[Req 54] -
        L'identificativo del quadro elettrico indicato nel punto luce (ElectricPanelID) DEVE essere
        uguale all'identificativo di uno dei quadri elettrici descritti nel documento
        (ElectricPanel/ElectricPanelID).</assert>

      <assert test="(//HomogeneousArea[HomogeneousAreaID = $homogArea])" flag="fatal">[Req 55] -
        L'identificativo della zona omogenea indicato nel punto luce (HomogeneousAreaID) DEVE essere
        uguale all'identificativo di una delle zond omogened descrittd nel documento
        (HomogeneousArea/HomogeneousAreaID).</assert>

    </rule>

    <rule context="//LightSpot/LightSpotDevice">
      <let name="deviceID" value="LightSpotDeviceID"/>

      <assert test="(count(//LightSpot/LightSource[LightSpotDeviceID = $deviceID]) = NumberOfLamps)"
        flag="fatal">[Req 85] - Il numero di lampade o moduli per singolo apparecchio
        (NumberOfLamps) DEVE essere uguale al numero di sorgenti luminose (blocchi LightSource)
        associate all'apparecchio.</assert>

      <assert
        test="(NumberOfLamps = 1) or (count(//LightSpot/LightSource[LightSpotDeviceID = $deviceID][LightSourceType = '09']) = 0)"
        flag="fatal">[Req 86] - Il numero di lampade o moduli per singolo apparecchio
        (NumberOfLamps) DEVE essere 1 in caso di apparecchio equipaggiato con tipologia di sorgente
        luminosa LED (//LightSource/LightSourceType = '09').</assert>

      <assert test="not(TerminalPower) or (TerminalPower[@uom = 'W'])" flag="warning">[Racc 19] -
        L'attributo XML @uom (unità di misura) dell'elemento TerminalPower DOVREBBE essere presente
        e valorizzato con il valore prefissato "W".</assert>

      <assert test="(Owner = '01') or (Owner = '02')" flag="warning">[Racc 20] - La proprietà del
        punto luce (Owner) DOVREBBE essere sempre indicata (si sconsiglia l'uso dei valori di
        indeterminatezza).</assert>

      <assert
        test="not(UpwardEmission) or (UpwardEmission[@uom] and not(UpwardEmission/@uom = '')) or (UpwardEmission[@xsi:nil = 'true'])"
        flag="fatal">[Req 97] - Se l'elemento UpwardEmission è presente, il suo attributo XML @uom
        (unità di misura) DEVE essere presente e valorizzato.</assert>

      <assert test="not(Flux) or (Flux[@uom = 'lm']) or (Flux[@xsi:nil = 'true'])" flag="warning"
        >[Racc 21] - L'attributo XML @uom (unità di misura) dell'elemento Flux DOVREBBE essere
        presente e valorizzato con il valore prefissato "lm".</assert>

      <assert
        test="(Ipea2013 = '91') or (Ipea2013 = '93') or (Ipea2013 = '94') or (Ipea2018 = '91') or (Ipea2018 = '93') or (Ipea2018 = '94')"
        flag="fatal">[Req 95] - Se è stato valorizzato l'indice IPEA 2013 (Ipea2013), l'indice IPEA
        2018 (Ipea2018) DEVE assumere uno dei valori di indeterminatezza.</assert>

    </rule>

    <rule context="//LightSpot/LightSpotEquipment">
      <let name="homoAreaID" value="preceding-sibling::HomogeneousAreaID"/>
      <let name="pointID" value="gml:Point/@gml:id"/>
      <assert
        test="(gml:Point/@gml:id) and (count(//HomogeneousArea[gml:MultiPoint/gml:pointMember/@xlink:href = $pointID][HomogeneousAreaID = $homoAreaID]) = 1)"
        flag="fatal">[Req 118] - L'identificativo geografico del punto luce DEVE essere fornito e
        DEVE essere uguale ad uno dei riferimenti geografici dei punti luce indicati nella Zona
        Omogenea di appartenenza (zona omoegenea <value-of select="$homoAreaID"/>)</assert>

      <assert test="not(Height) or (Height[@uom = 'm'])" flag="warning">[Racc 15] - L'attributo XML
        @uom (unità di misura) dell'elemento Height DOVREBBE essere presente e valorizzato con il
        valore prefissato "m".</assert>

      <assert test="not(Incline) or (Incline[@uom = '°']) or (Incline[@xsi:nil = 'true'])"
        flag="warning">[Racc 16] - L'attributo XML @uom (unità di misura) dell'elemento Incline
        DOVREBBE essere presente e valorizzato con il valore prefissato "°".</assert>

      <assert test="not(Distance) or (Distance[@uom = 'm']) or (Distance[@xsi:nil = 'true'])"
        flag="warning">[Racc 17] - L'attributo XML @uom (unità di misura) dell'elemento Distance
        DOVREBBE essere presente e valorizzato con il valore prefissato "m".</assert>

      <assert test="not(Length) or (Length[@uom = 'm']) or (Length[@xsi:nil = 'true'])"
        flag="warning">[Racc 18] - L'attributo XML @uom (unità di misura) dell'elemento Length
        DOVREBBE essere presente e valorizzato con il valore prefissato "m".</assert>

      <assert
        test="((Distance) and ((EquipmentType = '01') or (EquipmentType = '03'))) or not(Distance) or (Distance[@xsi:nil = 'true'])"
        flag="fatal">[Req 59] - Se la tipologia installazione (EquipmentType) è diversa da "su palo"
        o "su braccio", la distanza del sostegno dall’inizio della carreggiata (Distance) NON DEVE
        essere presente o, se presente, DEVE assumere il valore nullo.</assert>

      <assert
        test="((Length) and ((EquipmentType = '01') or (EquipmentType = '03'))) or not(Length) or (Length[@xsi:nil = 'true'])"
        flag="fatal">[Req 61] - Se la tipologia installazione (EquipmentType) è diversa da "su palo"
        o "su braccio", la lunghezza braccio (Length) NON DEVE essere presente o, se presente, DEVE
        assumere il valore nullo.</assert>

    </rule>

    <rule context="//LightSpot/LightSource">
      <let name="deviceID" value="LightSpotDeviceID"/>

      <assert test="(preceding-sibling::LightSpotDevice[LightSpotDeviceID = $deviceID])"
        flag="fatal">[Req 96] - L'identificativo dell'apparecchio indicato nella sorgente luminosa
        (LightSpotDeviceID) DEVE essere uguale all'identificativo di uno degli apparecchi
        appartenenti al punto luce a cui è associata la sorgente luminosa.</assert>

      <assert test="not(NominalPower) or (NominalPower[@uom = 'W'])" flag="warning">[Racc 22] -
        L'attributo XML @uom (unità di misura) dell'elemento NominalPower DOVREBBE essere presente e
        valorizzato con il valore prefissato "W".</assert>

      <assert test="not(NominalLuminousFlux) or (NominalLuminousFlux[@uom = 'lm']) or (NominalLuminousFlux[@xsi:nil = 'true'])" flag="warning"
        >[Racc 23] - L'attributo XML @uom (unità di misura) dell'elemento NominalLuminousFlux
        DOVREBBE essere presente e valorizzato con il valore prefissato "lm".</assert>

      <assert test="not(CCT) or (CCT[@uom = 'k']) or (CCT[@xsi:nil = 'true'])" flag="warning">[Racc
        24] - L'attributo XML @uom (unità di misura) dell'elemento CCT DOVREBBE essere presente e
        valorizzato con il valore prefissato "k".</assert>

    </rule>

    <rule context="//HomogeneousArea">
      <let name="homogArea" value="HomogeneousAreaID"/>
      <assert test="(count(//LightSpot[HomogeneousAreaID = $homogArea]) &gt; 0)">[Req 119] - La zona
        omogenea DEVE avere almeno un Punto luce (verifica la zona omogenea <value-of
          select="$homogArea"/>)</assert>
      <assert test="not(GridLength) or (GridLength[@uom = 'm'])" flag="warning">[Racc 25] -
        L'attributo XML @uom (unità di misura) dell'elemento GridLength DOVREBBE essere presente e
        valorizzato con il valore prefissato "m".</assert>

      <assert test="not(GridWidth) or (GridWidth[@uom = 'm'])" flag="warning">[Racc 26] -
        L'attributo XML @uom (unità di misura) dell'elemento GridWidth DOVREBBE essere presente e
        valorizzato con il valore prefissato "m".</assert>

      <assert
        test="not(AreaSurface) or (AreaSurface[@uom = 'm2']) or (AreaSurface[@xsi:nil = 'true'])"
        flag="warning">[Racc 27] - L'attributo XML @uom (unità di misura) dell'elemento AreaSurface
        DOVREBBE essere presente e valorizzato con il valore prefissato "m2".</assert>

      <assert
        test="not(FootpathWidth) or (FootpathWidth[@uom = 'm']) or (FootpathWidth[@xsi:nil = 'true'])"
        flag="warning">[Racc 29] - L'attributo XML @uom (unità di misura) dell'elemento
        FootpathWidth DOVREBBE essere presente e valorizzato con il valore prefissato "m".</assert>

      <assert test="not(DistanceBetweenLightSpots) or (DistanceBetweenLightSpots[@uom = 'm'])"
        flag="warning">[Racc 30] - L'attributo XML @uom (unità di misura) dell'elemento
        DistanceBetweenLightSpots DOVREBBE essere presente e valorizzato con il valore prefissato
        "m".</assert>

      <assert
        test="not(OtherFootpathWidth) or (OtherFootpathWidth[@xsi:nil = 'true']) or (OtherFootpathWidth[@uom = 'm'])"
        flag="warning">[Racc 31] - L'attributo XML @uom (unità di misura) dell'elemento
        OtherFootpathWidth DOVREBBE essere presente e valorizzato con il valore prefissato
        "m".</assert>

      <assert
        test="(not(AreaTypology = '01') and ((RoadwayType = '91') or (RoadwayType = '93') or (RoadwayType = '94'))) or ((AreaTypology = '01') and (not(RoadwayType = '91') and not(RoadwayType = '93') and not(RoadwayType = '94')))"
        flag="fatal">[Req 70] - Se la tipologia di area illuminata (AreaTypology) è diversa da 'area
        di circolazione veicolare', il tipo carreggiata (RoadwayType) DEVE essere valorizzato con
        uno dei valori di indeterminatezza, altrimenti DEVE essere indicato uno dei tipi carreggiata
        previsti.</assert>

      <assert
        test="(AreaTypology = '01') or (not(NumberOfSecondRoadwayLanes)) or (NumberOfSecondRoadwayLanes[@xsi:nil = 'true'])"
        flag="fatal">[Req 73] - Se la tipologia di area illuminata (AreaTypology) è diversa da “area
        di circolazione veicolare”, il numero di corsie seconda carreggiata
        (NumberOfSecondRoadwayLanes) NON DEVE presente o, se presente, assumere il valore
        nullo.</assert>

      <assert
        test="((RoadwayType = '02') or (RoadwayType = '03')) or (not(NumberOfSecondRoadwayLanes)) or (NumberOfSecondRoadwayLanes[@xsi:nil = 'true'])"
        flag="warning">[Racc 28] - Il numero di corsie seconda carreggiata DOVREBBE essere
        valorizzato solo se il tipo di carreggiata (RoadwayType) è 'due carreggiate simmetriche' o
        'due carreggiate asimmetriche'.</assert>

      <assert
        test="(not(AreaTypology = '01') and ((RoadLightSpotAllocation = '91') or (RoadLightSpotAllocation = '93') or (RoadLightSpotAllocation = '94'))) or ((AreaTypology = '01') and (not(RoadLightSpotAllocation = '91') and not(RoadLightSpotAllocation = '93') and not(RoadLightSpotAllocation = '94')))"
        flag="fatal">[Req 75] - Se la tipologia di area illuminata (AreaTypology) è diversa da 'area
        di circolazione veicolare', l'elemento distribuzione stradale degli apparecchi
        (RoadLightSpotAllocation) DEVE essere valorizzato con il valore di indeterminatezza,
        altrimenti DEVE essere valorizzato con una delle opzioni previste.</assert>

      <assert
        test="(not(OtherRoadLightSpotAllocation) or (OtherRoadLightSpotAllocation[@xsi:nil = 'true'])) or ((AreaTypology = '01') and (OtherAreaTypology) and not(OtherAreaTypology[@xsi:nil = 'true']))"
        flag="fatal">[Req 76] - Se la tipologia di area illuminata (AreaTypology) è diversa da 'area
        di circolazione veicolare' o se è 'area di circolazione veicolare' ma non è stato
        valorizzato l'elemento 'altra tipologia di area illuminata' (OtherAreaTypology), l'elemento
        'altra distribuzione stradale degli apparecchi' (OtherRoadLightSpotAllocation) NON DEVE
        essere presente o, se presente, DEVE assumere il valore nullo.</assert>

      <assert
        test="not(AreaTypology = '01') or ((not(OtherLightSpotAllocation) or (OtherLightSpotAllocation[@xsi:nil = 'true'])))"
        flag="fatal">[Req 77] - Se la tipologia di area illuminata (AreaTypology) è uguale a 'area
        di circolazione veicolare', l'elemento 'altra distribuzione degli apparecchi'
        (OtherLightSpotAllocation) NON DEVE essere presente o, se presente, DEVE assumere il valore
        nullo.</assert>

      <assert test="(number(NumberOfLightSpots) >= number(NumberOfSupports))" flag="fatal">[Req 81]
        - Il numero totale apparecchi (NumberOfLightSpots) DEVE essere maggiore o uguale al numero
        totale dei sostegni (NumberOfSupports).</assert>

      <assert
        test="(number(NumberOfLightSpots) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice))"
        flag="fatal">[Req 82] - Il numero totale apparecchi (NumberOfLightSpots) DEVE essere uguale
        al numero di blocchi punto luce apparecchio (LightSpotDevice) collegati alla zona omogenea
        (ovvero appartenenti ad un LightSpot con HomogeneousAreaID uguale all'id della zona
        omogenea).</assert>

      <assert
        test="((Footpath = '02') or (not(OtherFootpathWidth) or (OtherFootpathWidth[@xsi:nil = 'true']))) and (not(number(OtherFootpathWidth) = number(FootpathWidth)))"
        flag="fatal">[Req 84] - La larghezza altro marciapiede (OtherFootpathWidth) non DEVE essere
        valorizzata in caso di opzione presenza di marciapiede (Footpath) diversa da "sì, su ambo i
        lati" o valore uguale a "larghezza marciapiede" (FootpathWidth).</assert>

      <assert
        test="(count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment/EquipmentType)) = 1)"
        flag="warning" properties="NoStd">[Racc 100] - I punti luce appartenenti ad una stessa zona
        omogenea DOVREBBERO avere la stessa tipologia di installazione (verifica i punti luce della
        zona omogenea <value-of select="$homogArea"/>).</assert>

      <assert
        test="(count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment/Height)) = 1)"
        flag="warning" properties="NoStd">[Racc 101] - I punti luce appartenenti ad una stessa zona
        omogenea DOVREBBERO avere la stessa altezza apparecchio (verifica i punti luce della zona
        omogenea <value-of select="$homogArea"/>).</assert>

      <assert
        test="
          ((count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment/Incline)) = 1) and (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment[Incline])))
          or (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment[Incline]) = 0)
          or (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment/Incline[@xsi:nil = 'true']))"
        flag="warning" properties="NoStd">[Racc 102] - I punti luce appartenenti ad una stessa zona
        omogenea DOVREBBERO avere la stessa inclinazione (verifica i punti luce della zona omogenea
          <value-of select="$homogArea"/>).</assert>

      <assert
        test="
          ((count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment/Distance)) = 1) and (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment[Distance])))
          or (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment[Distance]) = 0)
          or (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment/Distance[@xsi:nil = 'true']))"
        flag="warning" properties="NoStd">[Racc 103] - I punti luce appartenenti ad una stessa zona
        omogenea DOVREBBERO avere la stessa distanza sostegno dall'inizio della carreggiata
        (verifica i punti luce della zona omogenea <value-of select="$homogArea"/>).</assert>

      <assert
        test="
          ((count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment/Length)) = 1) and (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment[Length])))
          or (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment[Length]) = 0)
          or (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotEquipment/Length[@xsi:nil = 'true']))"
        flag="warning" properties="NoStd">[Racc 104] - I punti luce appartenenti ad una stessa zona
        omogenea DOVREBBERO avere la stessa lunghezza braccio (verifica i punti luce della zona
        omogenea <value-of select="$homogArea"/>).</assert>


      <assert
        test="(count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/LightSpotType)) = 1)"
        flag="warning" properties="NoStd">[Racc 105] - Gli apparecchi dei punti luce appartenenti ad
        una stessa zona omogenea DOVREBBERO essere della stessa tipologia (verifica i punti luce
        della zona omogenea <value-of select="$homogArea"/>).</assert>

      <assert
        test="(count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/NumberOfLamps)) = 1)"
        flag="warning" properties="NoStd">[Racc 106] - Gli apparecchi dei punti luce appartenenti ad
        una stessa zona omogenea DOVREBBERO avere lo stesso numero di lampade o moduli per singolo
        apparecchio (verifica i punti luce della zona omogenea <value-of select="$homogArea"
        />).</assert>
      <assert
        test="(count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/TerminalPower)) = 1)"
        flag="warning" properties="NoStd">[Racc 107] - Gli apparecchi dei punti luce appartenenti ad
        una stessa zona omogenea DOVREBBERO avere la stessa potenza ai morsetti (verifica i punti
        luce della zona omogenea <value-of select="$homogArea"/>).</assert>
      <assert
        test="(count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/Owner)) = 1)"
        flag="warning" properties="NoStd">[Racc 108] - La proprietà dei punti luce appartenenti ad
        una stessa zona omogenea DOVREBBE essere la stessa (verifica i punti luce della zona
        omogenea <value-of select="$homogArea"/>).</assert>
      <assert
        test="(count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/Ipea2013)) = 1)"
        flag="warning" properties="NoStd">[Racc 109] - Gli apparecchi dei punti luce appartenenti ad
        una stessa zona omogenea DOVREBBERO avere lo stesso indice ipea (cam 2013) (verifica i punti
        luce della zona omogenea <value-of select="$homogArea"/>).</assert>
      <assert
        test="(count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/Ipea2018)) = 1)"
        flag="warning" properties="NoStd">[Racc 110] - Gli apparecchi dei punti luce appartenenti ad
        una stessa zona omogenea DOVREBBERO avere lo stesso indice ipea* (cam 2018) (verifica i
        punti luce della zona omogenea <value-of select="$homogArea"/>).</assert>

      <assert
        test="
          ((count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/UpwardEmission)) = 1) and (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice[UpwardEmission])))
          or (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice[UpwardEmission]) = 0)
          or (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/UpwardEmission[@xsi:nil = 'true']))"
        flag="warning" properties="NoStd">[Racc 111] - Gli apparecchi dei punti luce appartenenti ad
        una stessa zona omogenea DOVREBBERO avere la stessa emissione diretta verso l'alto (verifica
        i punti luce della zona omogenea <value-of select="$homogArea"/>).</assert>

      <assert
        test="
          (count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/UpwardEmission/@uom)) = 1)
          or (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/UpwardEmission) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/UpwardEmission[@xsi:nil = 'true']))"
        flag="fatal">[Req 112] - L'emissione diretta verso l'alto degli apparecchi dei punti luce
        appartenenti ad una stessa zona omogenea DEVE essere espressa secondo la stessa unità di
        misura (verifica gli apparecchi della zona omogenea <value-of select="$homogArea"
        />).</assert>

      <assert
        test="
          ((count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/CutOffFlag)) = 1) and (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice[CutOffFlag])))
          or (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice[CutOffFlag]) = 0)
          or (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/CutOffFlag[@xsi:nil = 'true']))"
        flag="warning" properties="NoStd">[Racc 113] - Gli apparecchi dei punti luce appartenenti ad
        una stessa zona omogenea DOVREBBERO avere la stessa schermatura (verifica gli apparecchi
        della zona omogenea <value-of select="$homogArea"/>).</assert>
      <assert
        test="
          (count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/Flux)) = 1)
          or (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSpotDevice/Flux[@xsi:nil = 'true']))"
        flag="warning" properties="NoStd">[Racc 114] - Gli apparecchi dei punti luce appartenenti ad
        una stessa zona omogenea DOVREBBERO avere lo stesso flusso caratteristico (verifica gli
        apparecchi della zona omogenea <value-of select="$homogArea"/>).</assert>

      <assert
        test="(count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSource/LightSourceType)) = 1)"
        flag="warning" properties="NoStd">[Racc 115] - I punti luce appartenenti ad una stessa zona
        omogenea DOVREBBERO avere la stessa tipologia di sorgente luminosa (verifica gli apparecchi
        della zona omogenea <value-of select="$homogArea"/>).</assert>

      <assert
        test="(count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSource/NominalPower)) = 1)"
        flag="warning" properties="NoStd">[Racc 116] - Le sorgenti luminose dei punti luce
        appartenenti ad una stessa zona omogenea DOVREBBERO avere la stessa potenza (verifica gli
        apparecchi della zona omogenea <value-of select="$homogArea"/>).</assert>

      <assert
        test="(count(distinct-values(//LightSpot[HomogeneousAreaID = $homogArea]/LightSource/NominalLuminousFlux)) = 1)
        or (count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSource) = count(//LightSpot[HomogeneousAreaID = $homogArea]/LightSource/NominalLuminousFlux[@xsi:nil = 'true']))"
        flag="warning" properties="NoStd">[Racc 117] - Le sorgenti luminose dei punti luce
        appartenenti ad una stessa zona omogenea DOVREBBERO avere lo stesso flusso luminoso
        (verifica gli apparecchi della zona omogenea <value-of select="$homogArea"/>).</assert>
    </rule>

    <rule context="//gml:Point">
      <assert
        test="(@srsDimension) and not(@srsDimension = '') and (@srsName) and not(@srsName = '') and (not(normalize-space(.) = ''))"
        flag="fatal">[Req 122] - Il Punto geografico e i suoi attributi 'srsDimension' e 'srsName' DEVONO essere forniti e valorizzati.</assert>
    </rule>
    
    
    <rule context="//gml:Polygon">
      <assert test="(@srsName) and not(@srsName = '') and (not(normalize-space(.) = ''))" flag="fatal">[Req 124] - L'Area geografica e il suo attributo
        'srsName' DEVE essere fornito e valorizzato.</assert>
    </rule>
    
    <rule context="//gml:MultiPoint">
      <assert test="(@srsName) and not(@srsName = '')" flag="warning">[Racc 123] - L'attributo
        'srsName' associato al riferimento geografico DOVREBBE essere fornito e
        valorizzato.</assert>
    </rule>

    <rule context="//gml:MultiPoint/gml:pointMember">
      <let name="refId" value="@xlink:href"/>
      <assert test="(count(//LightSpot/LightSpotEquipment/gml:Point[@gml:id = $refId]) = 1)"
        flag="fatal">[Req 121] - Il riferimento geografico di un Punto luce indicato nella zona
        omogenea DEVE esistere nel documento.</assert>

    </rule>

    <rule context="(//*)">
      <assert
        test="((namespace-uri() = 'http://www.opengis.net/gml/3.2') and ((local-name() = 'pointMember') or (count(child::gml:*) &gt; 0))) or (.[@xsi:nil = 'true']) or (not(normalize-space(.) = ''))"
        flag="fatal">[Req 0] - Ogni elemento presente nel documento XML DEVE essere valorizzato o,
        se ammesso, settato a nullo. </assert>
      <assert test="not(.[@xsi:nil = 'true'] and .[@uom])" flag="warning">[Racc 0] - Se un elemento
        è settato a nullo, l'unità di misura NON DOVREBBE essere presente. </assert>

    </rule>

  </pattern>
</schema>
