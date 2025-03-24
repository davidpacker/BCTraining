namespace aldev.vendorQuality.VendoerQuality;

using Microsoft.Purchases.Document;


pageextension 50800 "Purchase Order Ext" extends "Purchase Order"
{
    layout
    {
        addafter("Buy-from Vendor Name")
        {
            field("Vendor Quality Rating"; GetVendorQualityRating())
            {
                ApplicationArea = All;
                Editable = false;
                Style = Favorable;
                StyleExpr = IsVendorAcceptable;
                ToolTip = 'Shows the quality rating for this vendor';
            }
        }
    }

    actions
    {
        addafter("F&unctions")
        {
            action(ViewVendorQuality)
            {
                ApplicationArea = All;
                Caption = 'Vendor Quality Assessment';
                Image = QualificationOverview;
                ToolTip = 'View the quality assessment for this vendor';

                trigger OnAction()
                var
                    VendorQualityAssessment: Record "Vendor Quality Assessment";
                begin
                    if not VendorQualityAssessment.Get(Rec."Buy-from Vendor No.") then begin
                        VendorQualityAssessment.Init();
                        VendorQualityAssessment."Vendor No." := Rec."Buy-from Vendor No.";
                        VendorQualityAssessment.Insert(true);
                    end;
                    Page.Run(Page::"Vendor Quality Card", VendorQualityAssessment);
                end;
            }
        }
        modify("Release")
        {
            trigger OnBeforeAction()
            begin
                begin
                    if not IsVendorAcceptable then
                        Error('Cannot release purchase order. Vendor quality rating is below acceptable level.');
                end;
            end;
        }
    }

    var
        VendorQualityMgt: Codeunit "Vendor Quality Management";
        IsVendorAcceptable: Boolean;

    trigger OnAfterGetRecord()
    begin
        IsVendorAcceptable := VendorQualityMgt.IsVendorQualityAcceptable(Rec."Buy-from Vendor No.");
    end;

    local procedure GetVendorQualityRating(): Text
    begin
        exit(VendorQualityMgt.GetVendorRatingText(Rec."Buy-from Vendor No."));
    end;



}