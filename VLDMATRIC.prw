#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "FWMVCDEF.ch"

#Define CLRF Chr(10) + Chr(13)

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
@Type User Function
@Since 15/10/2019
@Version 1.0
@Return aMenu, Array, Object, Vetor contendo as operações da rotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
    Local aMenu := {}

    ADD OPTION aMenu TITLE "Ajustar"   ACTION "MsgInfo('Ajustar')"   OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION aMenu TITLE "Atualizar" ACTION "MsgInfo('Atualizar')" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
Return (aMenu)

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse para exibição das matriculas incorretas

@Author Thiago Fernandes da Silva
@Type User Function
@Since 15/10/2019
@Version 1.0
@Return oBrowse, Object, Objeto contendo as definições da browser
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()
    Local aTableDef := TableDef()
    
    oBrowse:SetAlias("SB1")
    oBrowse:SetMenuDef("VLDMATRIC")
    oBrowse:SetDescription("Matrículas Divergentes")
    oBrowse:DisableDetails()

    oBrowse:SetIniWindow({|| MsgInfo("Esta rotina tem como objetivo validar e ajustar " +;
                            "o controle de matrículas enviados ao eSocial.", "Bem-vindo!")})
Return (oBrowse)

//-------------------------------------------------------------------
/*/{Protheus.doc} TableDef
Browse para exibição das matriculas incorretas

@Author Thiago Fernandes da Silva
@Type User Function
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
    SQLToTrb(cQuery, aField, cAlias)
    DbGoTop()

    For nX := 1 To Len(aIndex)
        aIndex[nX] := aIndex[nX][1] + aIndex[nX][2]
    Next nX

    AAdd(aTable, cAlias)
    AAdd(aTable, aIndex)
    AAdd(aTable, aField)
Return (aTable)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDiagnose
Identica as matriculas incorretas e as retorna para o browser

@Author Thiago Fernandes da Silva7
@Type User Function
@Since 15/10/2019
@Version 1.0
@Return cAlias, Character, Alias da tabela temporária
/*/
//-------------------------------------------------------------------
Function U_TAFDiagnose()
    Local cQuery := "SELECT "
    Local cAlias := GetNextAlias()

	cQuery += "SRA.RA_FILIAL, SRA.RA_NOME, SRA.RA_CIC, SRA.RA_CODUNIC, SRA.R_E_C_N_O_, SRA.RA_SITFOLH,  SRA.D_E_L_E_T_"
	cQuery += "FROM " + RetSQLName("SRA") + " SRA " + CLRF
    cQuery += "JOIN " + RetSQLName("C9V") + " C9V ON  RA_CIC = C9V_CPF AND RA_SITFOLH='' AND C9V_DTTRAN='' AND RA_FILIAL=C9V_FILIAL  AND C9V_NOMEVE ='S2200'" + CLRF
    cQuery += "	AND RA_CODUNIC <> C9V_MATRIC AND C9V.D_E_L_E_T_ != '*' AND C9V_ATIVO = 1 AND RA_FILIAL = C9V_FILIAL" + CLRF
    cQuery += " AND SRA.D_E_L_E_T_ <> '*'"

    TCQUERY cQuery ALIAS cAlias NEW    
Return (cAlias)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFBtnOk
Ajusta as matriculas com divergência (alteração realizada na SRA)

@Author  Thiago Fernandes da Silva
@Type User Function
@Since   15/10/2019
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFBtnOk() 
    Local cQuery := "UPDATE "+ RetSQLName("SRA") + CLRF

    cQuery += "SET  RA_CODUNIC = C9V.C9V_MATRIC FROM " + RetSQLName("SRA") + " SRA "  + CLRF
    cQuery += "INNER JOIN "+ RetSQLName("C9V") + " C9V ON  RA_CIC = C9V_CPF AND RA_SITFOLH='' AND C9V_DTTRAN='' AND RA_FILIAL=C9V_FILIAL  AND C9V_NOMEVE ='S2200'" + CLRF
    cQuery += "	AND RA_CODUNIC <> C9V_MATRIC AND C9V.D_E_L_E_T_ != '*' AND C9V_ATIVO = 1 AND RA_FILIAL = C9V_FILIAL" + CLRF
    cQuery += " AND SRA.D_E_L_E_T_ <> '*'"

    If (TCSQLExec(cQuery) > 0 )
        MsgInfo("Alterado com sucesso!")
    Else 
        TCQueryError()
    EndIf 
Return (NIL)
