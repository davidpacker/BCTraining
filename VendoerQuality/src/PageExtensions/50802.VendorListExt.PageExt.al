namespace aldev.vendorQuality.VendoerQuality;

using Microsoft.Purchases.Vendor;

pageextension 50802 "Vendor List Ext" extends "Vendor List"
{
    layout
    {
        addafter(Name)
        {
            field("Vendor Score"; Rec."Vendor Score")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the quality score for this vendor';
                Style = Favorable;
                StyleExpr = IsVendorScoreAcceptable;
            }
        }
    }

    actions
    {
        addafter("Bank Accounts")
        {
            action(VendorQualityAssessment)
            {
                ApplicationArea = All;
                Caption = 'Quality Assessment';
                Image = QualificationOverview;
                ToolTip = 'View or update the quality assessment for the selected vendor';
                RunObject = page "Vendor Quality Card";
                RunPageLink = "Vendor No." = field("No.");

                trigger OnAction()
                var
                    VendorQualityAssessment: Record "Vendor Quality Assessment";
                begin
                    if not VendorQualityAssessment.Get(Rec."No.") then begin
                        VendorQualityAssessment.Init();
                        VendorQualityAssessment."Vendor No." := Rec."No.";
                        VendorQualityAssessment.Insert(true);
                    end;
                end;
            }
        }
    }

    var
        IsVendorScoreAcceptable: Boolean;
        VendorQualitySetup: Record "Vendor Quality Setup";

    trigger OnAfterGetCurrRecord()
    begin
        if not VendorQualitySetup.Get() then begin
            VendorQualitySetup.Init();
            VendorQualitySetup.Insert();
        end;

        Rec.CalcFields("Vendor Score");
        IsVendorScoreAcceptable := Rec."Vendor Score" >= VendorQualitySetup."Minimum Accepted Vendor Rate";
    end;
}