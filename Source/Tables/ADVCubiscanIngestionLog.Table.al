/// <summary>
/// Logs the json file being uploaded and what lines are updated for items and dimensiosn
/// </summary>
table 50011 "ADV Cubiscan Ingestion Log"
{
    Caption = 'Cubiscan Processing Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
            NotBlank = true;
        }
        field(2; "TimeIngested"; DateTime)
        {
            Caption = 'TimeIngested';
        }
        field(3; "JSON File Name"; Text[100])
        {
            Caption = 'JSON File Name';
        }
        field(4; "Barcode"; Text[50])
        {
            Caption = 'Barcode';
        }
        field(5; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(6; "Unit of Measure"; Text[20])
        {
            Caption = 'Unit of Measure';
        }
        field(7; "Net Length"; Decimal)
        {
            Caption = 'Net Length';
        }
        field(8; "Net Width"; Decimal)
        {
            Caption = 'Net Width';
        }
        field(9; "Net Height"; Decimal)
        {
            Caption = 'Net Height';
        }
        field(10; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
        }
        field(11; "Net Volume"; Decimal)
        {
            Caption = 'Net Volume';
        }
        field(12; "Net Dim Wgt"; Decimal)
        {
            Caption = 'Net Dim Wgt';
        }
        field(13; "Description"; Text[100])
        {
            Caption = 'Description';

        }
        field(14; "User ID"; Code[50])
        {
            Caption = 'User ID';
        }
        field(15; "Status"; Option)
        {
            Caption = 'Status';
            OptionMembers = Success,Failure;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(IdxTime; "TimeIngested")
        {
            Clustered = false;
        }
    }
}
