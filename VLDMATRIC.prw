#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "FWMVCDEF.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} VldMatric
Disponibiliza o browser para ajuste das matriculas incorretas

@Author Thiago Fernandes da Silva
@Type User Function
@Since 15/10/2019
@Version 1.0
/*/
//-------------------------------------------------------------------
Function U_VldMatric()
    Local oBrowse := FwLoadBrw("VLDMATRIC")
    oBrowse:Activate()
Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição das operações da rotina

@Author Thiago Fernandes da Silva
@Type Static Function
@Since 15/10/2019
@Version 1.0
@Return aMenu, Array, Object, Vetor contendo as operações da rotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
    Local aMenu := {}

    ADD OPTION aMenu TITLE "Ajustar"   ACTION "U_TAFBtnOk"           OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION aMenu TITLE "Atualizar" ACTION "MsgInfo('Atualizar')" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
Return (aMenu)

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse para exibição das matriculas incorretas

@Author Thiago Fernandes da Silva
@Type Static Function
@Since 15/10/2019
@Version 1.0
@Return oBrowse, Object, Objeto contendo as definições da browser
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()
    Local aTableDef := TableDef()
    
    oBrowse:SetTemporary(.T.)
    oBrowse:SetAlias(aTableDef[1])
    oBrowse:SetQueryIndex(aTableDef[2])
    oBrowse:SetFields(aTableDef[3])
    oBrowse:SetFieldFilter(GenFilterFld(aTableDef[3]))
    oBrowse:DisableDetails()
    oBrowse:SetDescription("Matrículas Divergentes")
    oBrowse:SetMenuDef("VLDMATRIC")

    oBrowse:SetIniWindow({|| MsgInfo("Esta rotina tem como objetivo validar e ajustar " +;
                            "o controle de matrículas enviados ao eSocial.", "Bem-vindo!")})
Return (oBrowse)

//-------------------------------------------------------------------
/*/{Protheus.doc} TableDef
Browse para exibição das matriculas incorretas

@Author Thiago Fernandes da Silva
@Type Static Function
@Since 15/10/2019
@Version 1.0
@Return aTable, Array, Vetor com o alias, os índices e os campos
/*/
//-------------------------------------------------------------------
Static Function TableDef()
    Local nX     := 0
    Local aAux   := {}
    Local aTable := {}
    Local aField := {}
    Local aIndex := {}
    Local cQuery := Space(0)
    Local cAlias := GetNextAlias()
    Local oTable := FwTemporaryTable():New(cAlias)

    AAdd(aField, {"Filial",      "TMP_FILIAL", "C", TamSX3("RA_FILIAL")[1],  0})
    AAdd(aField, {"Funcionário", "TMP_FUNC",   "C", TamSX3("RA_NOME")[1],    0})
    AAdd(aField, {"CPF",         "TMP_CPF",    "C", TamSX3("RA_CIC")[1],     0})
    AAdd(aField, {"Matric. TAF", "TMP_MTAF",   "C", TamSX3("C9V_MATRIC")[1], 0})
    AAdd(aField, {"Matric. GPE", "TMP_MGPE",   "C", TamSX3("RA_CODUNIC")[1], 0})

    aAux := Array(Len(aField))

    For nX := 1 To Len(aField)
        aAux[nX] := {aField[nX][2], aField[nX][3], aField[nX][4], aField[nX][5]}
    Next nX

    oTable:SetFields(aAux)

    AAdd(aIndex, {"TMP_FILIAL", "TMP_FUNC"})
    AAdd(aIndex, {"TMP_FILIAL", "TMP_CPF"})

    For nX := 1 To Len(aIndex)
        oTable:AddIndex(StrZero(nX, 2), aIndex[nX])
    Next nX

    oTable:Create()

    DbSelectArea(cAlias)

    cQuery += "SELECT SRA.RA_FILIAL AS TMP_FILIAL, SRA.RA_NOME AS TMP_FUNC, SRA.RA_CIC AS TMP_CPF, C9V.C9V_MATRIC AS TMP_MTAF, SRA.RA_CODUNIC AS TMP_MGPE "
    cQuery += "FROM " + RetSQLName("SRA") + " SRA "
    cQuery += "INNER JOIN " + RetSQLName("C9V") + " C9V " 
    cQuery += "ON SRA.RA_CIC = C9V.C9V_CPF AND SRA.RA_FILIAL = C9V.C9V_FILIAL AND SRA.RA_CODUNIC <> C9V.C9V_MATRIC AND RA_FILIAL = C9V_FILIAL "
    cQuery += "WHERE SRA.RA_SITFOLH = '' AND C9V.C9V_DTTRAN = '' AND C9V.C9V_NOMEVE = 'S2200' AND C9V.C9V_ATIVO = 1 AND C9V.D_E_L_E_T_ <> '*' AND SRA.D_E_L_E_T_ <> '*';"
    cQuery := ChangeQuery(cQuery)

    SQLToTrb(cQuery, aAux, cAlias)
    DbGoTop()

    For nX := 1 To Len(aIndex)
        aIndex[nX] := aIndex[nX][1] + "+" + aIndex[nX][2]
    Next nX

    AAdd(aTable, cAlias)
    AAdd(aTable, aIndex)
    AAdd(aTable, aField)
Return (aTable)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFBtnOk
Ajusta as matriculas com divergência (alteração realizada na SRA)

@Author  Thiago Fernandes da Silva
@Type User Function
@Since   15/10/2019
@Version 1.0
/*/
//-------------------------------------------------------------------
Function U_TAFBtnOk() 
    Local cQuery := "UPDATE " + RetSQLName("SRA") + " "

    cQuery += "SET RA_CODUNIC = C9V_MATRIC "
    cQuery += "FROM " + RetSQLName("SRA") + " SRA "
    cQuery += "INNER JOIN " + RetSQLName("C9V") + " C9V "
    cQuery += "ON SRA.RA_CIC = C9V.C9V_CPF AND SRA.RA_FILIAL = C9V.C9V_FILIAL AND SRA.RA_FILIAL = C9V.C9V_FILIAL AND SRA.RA_CODUNIC <> C9V.C9V_MATRIC "
    cQuery += "WHERE SRA.RA_CIC = '" + TMP_CPF + "' AND SRA.RA_SITFOLH = '' AND C9V.C9V_DTTRAN = '' AND C9V.C9V_ATIVO = 1 AND C9V.C9V_NOMEVE = 'S2200' AND C9V.D_E_L_E_T_ <> '*' AND SRA.D_E_L_E_T_ <> '*';"

    If (TCSQLExec(cQuery) == 0)
        RecLock(Alias(), .F.)
            DbDelete()
        MsUnlock()

        MsgInfo("Alterado com sucesso!")
    Else 
        TCSQLError()
    EndIf 
Return (NIL)

Static Function GenFilterFld(aFields)
    Local cPicture := Space(0)
    Local aFilter  := {}      
    Local nX       := 0       

    For nX := 1 To Len(aFields)
        Do Case
            Case (aFields[nX][3] == "C")
                cPicture := "@!"
            Case (aFields[nX][3] == "N")
                cPicture := "@E 99999999"
            Case (aFields[nX][3] == "D")
                cPicture := Space(0)
        EndCase

        AAdd(aFilter, {aFields[nX][2], aFields[nX][1], aFields[nX][3], aFields[nX][4], aFields[nX][5], cPicture})
    Next nX
Return (aFilter)