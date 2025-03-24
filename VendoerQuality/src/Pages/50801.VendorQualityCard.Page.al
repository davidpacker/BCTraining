namespace aldev.vendorQuality.VendoerQuality;

using Microsoft.Purchases.Vendor;

page 50801 "Vendor Quality Card"
{
    Caption = 'Vendor Quality Assessment';
    PageType = Card;
    SourceTable = "Vendor Quality Assessment";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor number';
                }
                field(VendorName; GetVendorName())
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the vendor';
                }
                field("Last Assessment Date"; Rec."Last Assessment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date of the last quality assessment';
                }
            }

            group(Scores)
            {
                Caption = 'Quality Scores';

                field("Item Quality Score"; Rec."Item Quality Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the score for item quality (0-10)';
                }
                field("Delivery On Time Score"; Rec."Delivery On Time Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the score for delivery timeliness (0-10)';
                }
                field("Item Packaging Score"; Rec."Item Packaging Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the score for item packaging quality (0-10)';
                }
                field("Pricing Score"; Rec."Pricing Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the score for pricing (0-10)';
                }
                field("Overall Rating"; Rec."Overall Rating")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = IsRatingFavorable;
                    ToolTip = 'Shows the overall weighted rating for this vendor';
                }
            }

            group(FinancialData)
            {
                Caption = 'Financial Data';

                field("Current Year Amount"; Rec."Current Year Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the total invoiced amount for the current year';
                }
                field("Previous Year Amount"; Rec."Previous Year Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the total invoiced amount for the previous year';
                }
                field("Two Years Ago Amount"; Rec."Two Years Ago Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the total invoiced amount from two years ago';
                }
                field("Amount Due"; Rec."Amount Due")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the total amount due for this vendor';
                }
                field("Amount To Pay"; Rec."Amount To Pay")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the total amount to pay that is not yet due';
                }
                field("Last Financial Update"; Rec."Last Financial Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows when the financial data was last updated';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateFinancialData)
            {
                ApplicationArea = All;
                Caption = 'Update Financial Data';
                Image = Refresh;
                ToolTip = 'Updates the financial data for this vendor';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.UpdateFinancialData();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        IsRatingFavorable: Boolean;

    trigger OnAfterGetRecord()
    var
        VendorQualitySetup: Record "Vendor Quality Setup";
    begin
        if not VendorQualitySetup.Get() then
            VendorQualitySetup.Insert();

        IsRatingFavorable := Rec."Overall Rating" >= VendorQualitySetup."Minimum Accepted Vendor Rate";
    end;

    local procedure GetVendorName(): Text[100]
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(Rec."Vendor No.") then
            exit(Vendor.Name);
        exit('');
    end;
}