// <copyright file="20250814121539_MakeNormalizedEmailRequired.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MeetlyOmni.Api.Migrations;

/// <inheritdoc />
public partial class MakeNormalizedEmailRequired : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AlterColumn<string>(
            name: "NormalizedEmail",
            table: "AspNetUsers",
            type: "character varying(256)",
            maxLength: 256,
            nullable: false,
            defaultValue: string.Empty,
            oldClrType: typeof(string),
            oldType: "character varying(256)",
            oldMaxLength: 256,
            oldNullable: true);
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AlterColumn<string>(
            name: "NormalizedEmail",
            table: "AspNetUsers",
            type: "character varying(256)",
            maxLength: 256,
            nullable: true,
            oldClrType: typeof(string),
            oldType: "character varying(256)",
            oldMaxLength: 256);
    }
}
