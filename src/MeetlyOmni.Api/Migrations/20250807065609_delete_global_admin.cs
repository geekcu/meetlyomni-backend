// <copyright file="20250807065609_delete_global_admin.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using System;

using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MeetlyOmni.Api.Migrations;

/// <inheritdoc />
public partial class Delete_global_admin : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(
            name: "CreatedAt",
            table: "AspNetRoles");

        migrationBuilder.DropColumn(
            name: "UpdatedAt",
            table: "AspNetRoles");

        migrationBuilder.AlterColumn<string>(
            name: "ConcurrencyStamp",
            table: "AspNetRoles",
            type: "text",
            nullable: false,
            defaultValueSql: "gen_random_uuid()::text",
            oldClrType: typeof(string),
            oldType: "character varying(255)",
            oldMaxLength: 255);
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AlterColumn<string>(
            name: "ConcurrencyStamp",
            table: "AspNetRoles",
            type: "character varying(255)",
            maxLength: 255,
            nullable: false,
            oldClrType: typeof(string),
            oldType: "text",
            oldDefaultValueSql: "gen_random_uuid()::text");

        migrationBuilder.AddColumn<DateTimeOffset>(
            name: "CreatedAt",
            table: "AspNetRoles",
            type: "timestamp with time zone",
            nullable: false,
            defaultValueSql: "NOW()");

        migrationBuilder.AddColumn<DateTimeOffset>(
            name: "UpdatedAt",
            table: "AspNetRoles",
            type: "timestamp with time zone",
            nullable: false,
            defaultValueSql: "NOW()");
    }
}
