#Include "TOTVS.ch"
#Include "TOPCONN.ch"

#Define CLRF Chr(10) + Chr(13)

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDMATRIC
Browse para exibicao das Matriculas Incorretas

@Author  Thiago Fernandes da Silva
@Type User Function
@Since   15/10/2019
@Version 1.0
/*/
//-------------------------------------------------------------------
Function U_VldMatric()
    Local oBrowse := FwLoadBrw("VLDMATRIC")
    oBrowse:Activate()
Return (NIL)

Static Function BrowseDef()
    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias("SB1")

    oBrowse:SetDescription("Matrículas Divergentes")
    oBrowse:DisableDetails()

    oBrowse:SetIniWindow({|| MsgInfo("Esta rotina tem como objetivo validar e ajustar " +;
                            "o controle de matrículas enviados ao eSocial.", "Bem-vindo!")})
Return (oBrowse)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDiagnose
Identica as matriculas incorretas e as retorna para o browser

@Author Thiago Fernandes da Silva7
@Type User Function
@Since 15/10/2019
@Version 1.0
@return cAlias, Character, Alias da tabela temporária
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
