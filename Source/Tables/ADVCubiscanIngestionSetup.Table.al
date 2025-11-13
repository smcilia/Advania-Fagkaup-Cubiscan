/// <summary>
/// Used so page opens, saves the name of last file uploaded
/// </summary>
table 50010 "ADV Cubiscan Ingestion Setup"
{
    Caption = 'Cubiscan Data Processing Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Key"; Code[10])
        {
            Caption = 'Key';

        }
        field(2; "Folder Location"; Text[250])
        {

            Caption = 'Folder Location';
        }
        field(3; "File Name"; Text[100])
        {

            Caption = 'File Name';
        }
        field(4; "Uploaded JSON File"; Media)
        {
            Caption = 'Uploaded JSON File';

            trigger OnValidate()
            begin
                if Rec."Uploaded JSON File".HasValue then begin
                    LastUpdate := CurrentDateTime;
                end;
            end;
        }
        field(5; LastUpdate; DateTime)
        {
            Caption = 'Last Updated';
        }
    }
    keys
    {
        key(PK; "Key")
        {
            Clustered = true;
        }
    }

}
