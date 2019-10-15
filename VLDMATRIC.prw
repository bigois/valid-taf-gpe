#Include "TOTVS.ch"
#Include "TOPCONN.ch"

#Define CLRF Chr(10) + Chr(13)

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDMATRIC
Browse para exibicao das Matriculas Incorretas

@Author  Thiago Fernandes da Silva
@Since   15/10/2019
@Version 1.0
/*/
//-------------------------------------------------------------------
Function U_VLDMATRIC()
    Local oSize      := FwDefSize():New(.F.)
    Local oDlgIds    := NIL
    Local oBrowseIds := NIL 

    DEFINE MSDIALOG oDlgIds TITLE "Matriculas Divergentes" FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] PIXEL
        oBrowseIds := MBrowse():New(NIL, NIL, NIL, "oBrowseIds")
            oBrowseIds:SetOwner(oDlgIds)

            oBrowseIds:AddButton("Ajustar Matriculas", {|| FwMsgRun(NIL, {|oMsg| BtnOk()}, "Ajuste de Matriculas", "Selecionando matriculas para ajuste...")}) 
            oBrowseIds:AddButton("Visualizar Registros", {|| oBrowseIds:ShowIdsDuplic()}) 
            oBrowseIds:AddButton("Exibir Matriculas Ajustadas", {|| oBrowseIds:ShowIdsAjusts()}) 
        oBrowseIds:Activate()

        MsGetDados():New(nLinIni + 084, nColIni, nLinFin, nColFin, nOpcx, "VLDMATRIC", NIL, NIL, .T., aAltera, NIL, NIL, 200)
    ACTIVATE MsDialog oDlgIds CENTERED 
Return (NIL)

Function U_TAFDiagnose(oMsgRun, oBrowseIds)
    Local cQuery := "SELECT "
    Local cAlias := GetNextAlias()

	cQuery += "SRA.RA_FILIAL, SRA.RA_NOME, SRA.RA_CIC, SRA.RA_CODUNIC, SRA.R_E_C_N_O_, SRA.RA_SITFOLH,  SRA.D_E_L_E_T_"
	cQuery += "FROM " + RetSQLName("SRA") + " SRA " + CLRF
    cQuery += "JOIN " + RetSQLName("C9V") + " C9V ON  RA_CIC = C9V_CPF AND RA_SITFOLH='' AND C9V_DTTRAN='' AND RA_FILIAL=C9V_FILIAL  AND C9V_NOMEVE ='S2200'" + CLRF
    cQuery += "	AND RA_CODUNIC <> C9V_MATRIC AND C9V.D_E_L_E_T_ != '*' AND C9V_ATIVO = 1 AND RA_FILIAL = C9V_FILIAL" + CLRF
    cQuery += " AND SRA.D_E_L_E_T_ <> '*'"

    TCQUERY cQuery ALIAS cAlias NEW    
Return (cAlias)

static function btnok() 

Local cUpdt := "" 

 cUpdt :="UPDATE "+ RetSqlName("SRA")             + CLRF
 cUpdt +="SET  RA_CODUNIC = C9V.C9V_MATRIC FROM " + RetSqlName("SRA") + " SRA "          + CLRF
 cUpdt +="INNER JOIN "+ RetSqlName("C9V") + " C9V ON  RA_CIC = C9V_CPF AND RA_SITFOLH='' AND C9V_DTTRAN='' AND RA_FILIAL=C9V_FILIAL  AND C9V_NOMEVE ='S2200'"                + CLRF
 cUpdt += "	AND RA_CODUNIC <> C9V_MATRIC AND C9V.D_E_L_E_T_ != '*' AND C9V_ATIVO = 1 AND RA_FILIAL = C9V_FILIAL"                          + CLRF
 cUpdt += " AND SRA.D_E_L_E_T_ <> '*'"

If tcsSqlExec(cUpdt) >0 
    msginfo("alterado com sucesso ")
Else 
    tcQueryerror()
endIf 


return 
