// <copyright file="20250814102056_fix_member_configuration.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MeetlyOmni.Api.Migrations;

/// <inheritdoc />
public partial class Fix_member_configuration : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        // Make index operations resilient if old indexes don't exist (e.g., fresh DB or prior rename applied)
        migrationBuilder.Sql("DROP INDEX IF EXISTS \"UK_Member_Org_Email\";");
        migrationBuilder.Sql("ALTER INDEX IF EXISTS \"IX_RaffleTickets_OrgId\" RENAME TO \"IX_RaffleTicket_OrgId\";");
        migrationBuilder.Sql("ALTER INDEX IF EXISTS \"IX_RaffleTickets_MemberId\" RENAME TO \"IX_RaffleTicket_MemberId\";");
        migrationBuilder.Sql("ALTER INDEX IF EXISTS \"UK_Member_Org_LocalNumber\" RENAME TO \"UK_Member_Org_LocalMemberNumber\";");

        migrationBuilder.AlterColumn<string>(
            name: "PasswordHash",
            table: "AspNetUsers",
            type: "text",
            nullable: true,
            oldClrType: typeof(string),
            oldType: "character varying(255)",
            oldMaxLength: 255);

        migrationBuilder.AlterColumn<string>(
            name: "NormalizedName",
            table: "AspNetRoles",
            type: "character varying(100)",
            maxLength: 100,
            nullable: false,
            oldClrType: typeof(string),
            oldType: "character varying(256)",
            oldMaxLength: 256);

        migrationBuilder.AlterColumn<string>(
            name: "Name",
            table: "AspNetRoles",
            type: "character varying(100)",
            maxLength: 100,
            nullable: false,
            oldClrType: typeof(string),
            oldType: "character varying(256)",
            oldMaxLength: 256);
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.RenameIndex(
            name: "IX_RaffleTicket_OrgId",
            table: "RaffleTickets",
            newName: "IX_RaffleTickets_OrgId");

        migrationBuilder.RenameIndex(
            name: "IX_RaffleTicket_MemberId",
            table: "RaffleTickets",
            newName: "IX_RaffleTickets_MemberId");

        migrationBuilder.RenameIndex(
            name: "UK_Member_Org_LocalMemberNumber",
            table: "AspNetUsers",
            newName: "UK_Member_Org_LocalNumber");

        migrationBuilder.AlterColumn<string>(
            name: "PasswordHash",
            table: "AspNetUsers",
            type: "character varying(255)",
            maxLength: 255,
            nullable: false,
            defaultValue: string.Empty,
            oldClrType: typeof(string),
            oldType: "text",
            oldNullable: true);

        migrationBuilder.AlterColumn<string>(
            name: "NormalizedName",
            table: "AspNetRoles",
            type: "character varying(256)",
            maxLength: 256,
            nullable: false,
            oldClrType: typeof(string),
            oldType: "character varying(100)",
            oldMaxLength: 100);

        migrationBuilder.AlterColumn<string>(
            name: "Name",
            table: "AspNetRoles",
            type: "character varying(256)",
            maxLength: 256,
            nullable: false,
            oldClrType: typeof(string),
            oldType: "character varying(100)",
            oldMaxLength: 100);

        migrationBuilder.CreateIndex(
            name: "UK_Member_Org_Email",
            table: "AspNetUsers",
            columns: new[] { "OrgId", "Email" },
            unique: true);
    }
}
