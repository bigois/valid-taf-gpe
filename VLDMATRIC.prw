#Include "TOTVS.ch"
#Include "TOPCONN.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDMATRIC
Browse para exibicao das Matriculas Incorretas

@Author  Thiago Fernandes da Silva
@Since   15/10/2019
@Version 1.0
/*/
//-------------------------------------------------------------------
User Function VLDMATRIC()

    Local oSize := Nil
    Local oDlgIds := Nil 

    Private oBrowseIds := Nil 

    oSize := FwDefSize():New(.F.)

    Define MsDialog oDlgIds Title "Matriculas Divergentes" From oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4]  Pixel //"Monitor e-Social - Visão Consolidada"

    oBrowseIds:= MBROWSE():New(,,,"oBrowseIds")
    oBrowseIds:SetOwner(oDlgIds)
    oBrowseIds:AddButton("Ajustar Matriculas.",{||FWMsgRun(,{|oMsg|btnok()(oMsg,oBrowseIds)},"Ajuste de Matriculas","Selecionando Matriculas para Ajuste ...") }) 
    oBrowseIds:AddButton("Visualizar Registros",{||oBrowseIds:showIdsDuplic()}) 
    oBrowseIds:AddButton("Exibir Matriculas Ajustadas",{||oBrowseIds:showIdsAjusts()}) 

    oBrowseIds:Activate()

    MsGetDados():New(nLinIni+084,nColIni,nLinFin,nColFin,nOpcx,"VLDMATRIC",,,.T.,aAltera,,,200)
    
    Activate MsDialog oDlgIds Centered 

Return Nil 

user Function TafBrwIdsDup(oMsgRun,oBrowseIds)

    Local cSql := ""
    Local cLastFil:= ""
    Local cFilbckp := ""
    Local aAreaSM0 := SM0->(getArea())
    Local cCodGrpEmp := FWGrpCompany()
    Local cNewId := ""
    Local cAliasTab := getnextalias()
    Local nTry := 0
    Local nRecTaf := 0
    Local lLoopId := .T.
    Local lChangeTab := .F.
    Local lMakeSomething := .F.
    Local oModel := Nil 
    Local cFonte := ""
    Local cNomeEvt := ""
    Local cSeed := ""
    Local nSeed := 0
    Local aCtdUpd := {}

    cSql := "SELECT"
	cSql += "SRA.RA_FILIAL, SRA.RA_NOME, SRA.RA_CIC, SRA.RA_CODUNIC, SRA.R_E_C_N_O_, SRA.RA_SITFOLH,  SRA.D_E_L_E_T_"
	cSql += "FROM " + RetSqlName("SRA") + " SRA "          + STR_PULA
    cSql += "JOIN " + RetSqlName("C9V") + " C9V ON  RA_CIC = C9V_CPF AND RA_SITFOLH='' AND C9V_DTTRAN='' AND RA_FILIAL=C9V_FILIAL  AND C9V_NOMEVE ='S2200'"                + STR_PULA
    cSql += "	AND RA_CODUNIC <> C9V_MATRIC AND C9V.D_E_L_E_T_ != '*' AND C9V_ATIVO = 1 AND RA_FILIAL = C9V_FILIAL"                          + STR_PULA
    cSql += " AND SRA.D_E_L_E_T_ <> '*'"

    TCQUERY cSql ALIAS cAliasTab NEW
    // TCQUERY cQuery ALIAS "DLG" NEW

    

    
Return  cAliasTab

static function btnok() 

Local cUpdt := "" 

 cUpdt :="UPDATE "+ RetSqlName("SRA")             + STR_PULA
 cUpdt +="SET  RA_CODUNIC = C9V.C9V_MATRIC FROM " + RetSqlName("SRA") + " SRA "          + STR_PULA
 cUpdt +="INNER JOIN "+ RetSqlName("C9V") + " C9V ON  RA_CIC = C9V_CPF AND RA_SITFOLH='' AND C9V_DTTRAN='' AND RA_FILIAL=C9V_FILIAL  AND C9V_NOMEVE ='S2200'"                + STR_PULA
 cUpdt += "	AND RA_CODUNIC <> C9V_MATRIC AND C9V.D_E_L_E_T_ != '*' AND C9V_ATIVO = 1 AND RA_FILIAL = C9V_FILIAL"                          + STR_PULA
 cUpdt += " AND SRA.D_E_L_E_T_ <> '*'"

If tcsSqlExec(cUpdt) >0 
    msginfo("alterado com sucesso ")
Else 
    tcsqlerror()
endIf 


return 
